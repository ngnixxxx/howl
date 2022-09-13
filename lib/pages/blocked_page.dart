import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/blocked.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/answer_layout.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/widgets/custom_dialog.dart';

class BlockedPage extends StatefulWidget {
  final User userProvider;

  const BlockedPage({Key key, this.userProvider}) : super(key: key);
  @override
  _BlockedPageState createState() => _BlockedPageState();
}

class _BlockedPageState extends State<BlockedPage> {
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();
  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
          child: Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  icon: Icon(Feather.arrow_left),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Blocked Users',
                    style: Theme.of(context).textTheme.headline5),
              ],
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream:
                _firebaseMethods.fetchBlocked(userId: widget.userProvider.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LinearProgressIndicator();
              }
              if (snapshot.data.docs.length == 0) {
                return Center(
                    child: Text('You blocked no one',
                        style: Theme.of(context).textTheme.bodyText1));
              }
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    Blocked blocked =
                        Blocked.fromMap(snapshot.data.docs[index].data());
                    return _buildBlockedListTile(blocked);
                  });
            }),
      ),
    );
  }

  _buildBlockedListTile(Blocked blocked) {
    return FutureBuilder<User>(
      future: _authMethods.getUserWithId(blocked.uid),
      builder: (context, snapshot) {
        User user = snapshot.data;
        if (!snapshot.hasData) {
          return ListTileShimmer();
        }
        return ListTile(
            onTap: () {
              List<User> userList = [];
              userList.add(user);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfilePage(
                            contact: userList,
                            userProvider: widget.userProvider,
                          )));
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(user.profileUrl),
            ),
            title: Text(user?.username,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .apply(fontSizeFactor: 1.3)),
            subtitle: user.name.isEmpty
                ? null
                : Text(user?.name,
                    style: Theme.of(context).textTheme.bodyText1),
            trailing: OutlinedButton(
              // borderSide: BorderSide(
              //     color: Theme.of(context).textTheme.bodyText1.color),
              child: Text('Unblock',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .apply(fontSizeFactor: 0.9)),
              onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return CustomDialog(
                      title: 'Unblock',
                      content: Text(
                        'Are you sure ${user.username} will be able to find you after unblocking?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      function: () {
                        _firebaseMethods.unblockUser(
                            widget.userProvider.id, user.id);
                        Navigator.pop(context);
                        Flushbar(
                          flushbarPosition: FlushbarPosition.BOTTOM,
                          backgroundColor: Theme.of(context).accentColor,
                          message: '${user.username} is unblocked',
                          duration: const Duration(milliseconds: 300),
                          isDismissible: true,
                          animationDuration: const Duration(milliseconds: 202),
                          margin: const EdgeInsets.all(20),
                        );
                      },
                      mainActionText: 'Unblock',
                      secondaryActionText: 'Let me think about it',
                      function1: () => Navigator.pop(context),
                    );
                  }),
            ));
      },
    );
  }
}

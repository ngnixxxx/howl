import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howl/models/request.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/answer_layout.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/utils/constants.dart';

class RequestsPages extends StatefulWidget {
  final User contact;
  final User userProvider;

  const RequestsPages({Key key, this.contact, this.userProvider})
      : super(key: key);
  @override
  _RequestPagesState createState() => _RequestPagesState();
}

class _RequestPagesState extends State<RequestsPages> {
  bool isFollowing;

  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  _setupIsFollowing(User userProvider) async {
    bool isFollowingUser = await _firebaseMethods.isFollowingUser(
        currentUserId: widget.contact.id, userId: userProvider.id);

    setState(() {
      isFollowing = isFollowingUser;
    });
  }

  @override
  void initState() {
    _setupIsFollowing(widget.userProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
            title: Text('Follow requests',
                style: Theme.of(context).textTheme.headline6)),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              _firebaseMethods.fetchReceivedRequests(userId: widget.contact.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data.docs.length == 0) {
              return Center(
                  child: Text('You have no requests',
                      style: Theme.of(context).textTheme.bodyText1));
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (BuildContext context, int index) {
                Request request =
                    Request.fromMap(snapshot.data.docs[index].data());
                return _buildRequestsTile(request, widget.userProvider);
              },
              itemCount: snapshot.data.docs.length,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestsTile(Request request, User userProvider) {
    return FutureBuilder<User>(
        future: _authMethods.getUserWithId(request.uid),
        builder: (context, snapshot) {
          User user = snapshot.data;
          return ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                radius: 24,
                child: user.profileUrl.isNotEmpty
                    ? CachedNetworkImageProvider(user.profileUrl)
                    : AssetImage(imageNotAvailable),
              ),
              title: Text(
                user?.username ?? '..',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: user.name.isNotEmpty
                  ? Text(
                      user?.name ?? '..',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  : null,
              trailing: _displayButtons(user, userProvider),
              onTap: () {
                List<User> users = [];
                users.add(user);
                users.add(widget.userProvider);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfilePage(
                            contact: users, userProvider: userProvider)));
              });
        });
  }

  Widget _displayButtons(User user, User userProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          width: 70,
          child: TextButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(isFollowing ? 'Follow Back' : 'Follow',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(fontSizeFactor: 0.8)),
              ),
              onPressed: () => _firebaseMethods.followUser(
                  currentUserId: userProvider.id, userId: user.id),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          height: 30,
          child: OutlinedButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Remove',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .apply(fontSizeFactor: 0.8)),
              ),
              onPressed: () => _firebaseMethods.deleteRequest(
                  currentUserId: userProvider.id, userId: user.id),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              )),
        ),
      ],
    );
  }
}

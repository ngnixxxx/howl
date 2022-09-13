import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/follower.dart';
import 'package:howl/models/user.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:provider/provider.dart';

class NewChatPage extends StatefulWidget {
  final User contact;

  NewChatPage({this.contact});
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  TextEditingController _searchController = TextEditingController();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  List<User> userList;
  List<String> selectedUser = [];
  List<DocumentSnapshot> snapshotData;

  var query;

  bool creating = false;

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {});
  }

  void toggleSelection(User user, int index) {
    if (selectedUser.contains(user.id)) {
      setState(() {
        selectedUser.remove(user.id);
        print(selectedUser.length);
      });
    } else {
      setState(() {
        selectedUser.add(user.id);
        print(selectedUser.length);
      });
    }
  }

  buildNewChatSuggestions(String query, UserProvider userProvider) {
    final List<User> suggestionList = query.isEmpty
        ? []
        : userList.where((User user) {
            String _getUsername = user.username.toLowerCase();
            String _getName = user.name.toLowerCase();
            String _query = query.toLowerCase();
            bool matchesName = _getName.contains(_query);
            bool matchesUsername = _getUsername.contains(_query);
            return (matchesName || matchesUsername);

            // (user.username.toLowerCase().contains(query.toLowerCase())
            //  || user.name.toLowerCase().contains(query.toLowerCase())));
          }).toList();

    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          User searchUser = User(
              id: suggestionList[index].id,
              profileUrl: suggestionList[index].profileUrl,
              name: suggestionList[index].name,
              username: suggestionList[index].username);
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // onTap: () {
            //   setState(() {
            //     isSelected[index] = !isSelected[index];
            //   });
            // },
            // selected: isSelected[index],
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: searchUser.profileUrl != null
                  ? CachedNetworkImageProvider(searchUser.profileUrl)
                  : const CachedNetworkImageProvider(imageNotAvailable),
            ),
            title: Text(
              searchUser.username,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            subtitle: searchUser.name.isNotEmpty
                ? Text(
                    searchUser.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                : null,
          );
        });
  }

  _buildNewChatTile(Follower follower, UserProvider userProvider,
      List<DocumentSnapshot> snapshotData, int index) {
    return FutureBuilder<User>(
        future: _authMethods.getUserWithId(follower.uid),
        builder: (context, snapshot) {
          User user = snapshot.data;
          if (!snapshot.hasData) {
            return const ListTileShimmer(
              padding: EdgeInsets.zero,
            );
          }
          return Container(
            child: ListTile(
              onTap: () {
                toggleSelection(user, index);
              },
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: user.profileUrl != null
                    ? CachedNetworkImageProvider(user.profileUrl)
                    : const CachedNetworkImageProvider(imageNotAvailable),
              ),
              title: Text(
                user?.username,
                style: selectedUser.contains(user.id)
                    ? Theme.of(context).textTheme.bodyText1.apply(
                        fontSizeFactor: 1.3,
                        fontWeightDelta: 500,
                        color: Theme.of(context).accentColor)
                    : Theme.of(context)
                        .textTheme
                        .bodyText1
                        .apply(fontSizeFactor: 1.3),
              ),
              subtitle: user.name.isNotEmpty
                  ? Text(
                      user?.name,
                      overflow: TextOverflow.ellipsis,
                      style: selectedUser.contains(user.id)
                          ? Theme.of(context).textTheme.bodyText1.apply(
                              fontWeightDelta: 500,
                              color: Theme.of(context).accentColor)
                          : Theme.of(context).textTheme.subtitle2,
                    )
                  : null,
              trailing: selectedUser.contains(user.id)
                  ? Container(
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).accentColor),
                      child: Icon(Feather.check,
                          color: Theme.of(context).accentIconTheme.color,
                          size: 20),
                    )
                  : Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .color))),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
            ),
          );
        });
  }

  void createChat(
      String currentUserId, List<String> userId, Timestamp currentTime) async {
    userId.add(currentUserId);
    await _firebaseMethods.addChat(
        currentUserId, userId, currentTime, null, false);
    setState(() {
      creating = false;
    });
    Navigator.pop(context);
    // Navigator.push(context, MaterialPageRoute(builder: (_)=> MessagesPage(userProvider: widget.contact, receiver: ,)))
  }

  void createGroupChat(String currentUserId, List<String> usersList,
      Timestamp currentTime, String groupName) async {
    usersList.add(currentUserId);
    await _firebaseMethods.addChat(
        currentUserId, usersList, currentTime, groupName, true);
    await _firebaseMethods.addRecieversChat(
        currentUserId, usersList, currentTime, groupName, true);

    setState(() {
      creating = false;
    });
    Navigator.pop(context);
    // Navigator.push(context, MaterialPageRoute(builder: (_)=> MessagesPage(userProvider: widget.contact, receiver: ,)))
  }

  // chipUsername() {
  //   for (var username = 0; username < selectedUser.length;) {
  //     return Text(selectedUser[username].username);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New', style: Theme.of(context).textTheme.headline5),
                selectedUser != null
                    ? Text('${selectedUser.length} users selected',
                        style: Theme.of(context).textTheme.bodyText1)
                    : Container(),
              ],
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextFormField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: _searchController,
                enabled: true,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: Theme.of(context).textTheme.bodyText1,
                  isDense: true,
                  prefixIcon: Icon(Feather.search,
                      color: Theme.of(context).primaryIconTheme.color),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Feather.x,
                              color: Theme.of(context).primaryIconTheme.color),
                          onPressed: _clearSearch(),
                        )
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
                radius: 24,
                child: Icon(FontAwesome.qrcode,
                    color: Theme.of(context).accentIconTheme.color),
                backgroundColor: Theme.of(context).accentColor),
            title: Text('Scan Code',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .apply(fontSizeFactor: 1.3)),
            onTap: () {},
          ),
          Expanded(
            child: Container(
              child: query == null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _firebaseMethods.fetchFollowing(
                          userId: widget.contact.id, orderBy: 'addedOn'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [LinearProgressIndicator()],
                          );
                        } else if (snapshot.data.docs.length == 0) {
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('You are following no one',
                                    style:
                                        Theme.of(context).textTheme.bodyText1)
                              ]);
                        } else {
                          snapshotData = snapshot.data.docs;

                          // isSelected = List<bool>.generate(
                          //     snapshotData.length, (_) => false).toList();

                          return ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              Follower follower = Follower.fromMap(
                                  snapshot.data.docs[index].data());

                              return _buildNewChatTile(
                                  follower, userProvider, snapshotData, index);
                            },
                            itemCount: snapshot.data.docs.length,
                          );
                        }
                      },
                    )
                  : buildNewChatSuggestions(query, userProvider),
            ),
          ),
          TextButton(
            onPressed: creating
                ? () {}
                : () {
                    Timestamp currentTime = Timestamp.now();
                    if (selectedUser.isEmpty) {
                      return Flushbar(
                        margin:
                            EdgeInsets.only(left: 20, right: 20, bottom: 65),
                        flushbarStyle: FlushbarStyle.FLOATING,
                        message: 'You must selected at least one user',
                        backgroundColor: Theme.of(context).accentColor,
                        animationDuration: Duration(milliseconds: 200),
                      )..show(context);
                    } else if (selectedUser.length == 1) {
                      print(selectedUser);
                      setState(() {
                        creating = true;
                      });
                      createChat(
                          userProvider.getUser.id, selectedUser, currentTime);
                    } else {
                      print(selectedUser);
                      String groupName;

                      return showModalBottomSheet(
                          isDismissible: false,
                          context: context,
                          builder: (_) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Group Name',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 20),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          hintText: 'Group Name',
                                          alignLabelWithHint: true,
                                          isDense: true,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never),
                                      onFieldSubmitted: (value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            groupName = selectedUser
                                                .asMap()
                                                .values
                                                .toString();
                                          });
                                        }
                                        setState(() {
                                          groupName = value;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(context).accentColor),
                                        onPressed: () {
                                          setState(() {
                                            creating = true;
                                          });
                                          createGroupChat(
                                              userProvider.getUser.id,
                                              selectedUser,
                                              currentTime,
                                              groupName);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 20),
                                          child: Text('Set Name',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )),
                                    const SizedBox(height: 20),
                                  ]),
                            );
                          });
                    }
                  },
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).accentColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)))),
            child: creating
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: const CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                        selectedUser.length > 1
                            ? 'Create Group'
                            : 'Start Conversation',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
          )
        ],
      ),
    );
  }
}

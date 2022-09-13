import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/home.dart';
import 'package:howl/models/follower.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:provider/provider.dart';

import 'answer_layout.dart';

class FollowingPage extends StatefulWidget {
  final User contact;
  final User userProvider;

  FollowingPage({this.contact, this.userProvider});
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage>
    with WidgetsBindingObserver {
  bool isFollowing;
  bool isOnline = true;
  List<User> userList;

  TextEditingController _searchController = TextEditingController();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  String query;

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      query = '';
    });
  }

  _setupIsFollowing(User userProvider) async {
    bool isFollowingUser = await _firebaseMethods.isFollowingUser(
        currentUserId: userProvider.id, userId: widget.contact.id);

    setState(() {
      isFollowing = isFollowingUser;
    });
  }

  Widget _displayButton(User user, UserProvider userProvider) {
    return SizedBox(
      height: 35,
      child: OutlinedButton(
          child: Text('Remove',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .apply(fontSizeFactor: 0.75)),
          onPressed: () => unfollowUser(user, userProvider),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )),
    );
  }

  Widget _buildFollowingTile(Follower following, UserProvider userProvider) {
    return FutureBuilder<User>(
        future: _authMethods.getUserWithId(following.uid),
        builder: (context, snapshot) {
          User user = snapshot.data;
          if (!snapshot.hasData) {
            return ProfileShimmer();
          }
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: user.profileUrl != null
                  ? CachedNetworkImageProvider(user.profileUrl)
                  : AssetImage(imageNotAvailable),
            ),
            title: Text(
              user?.username ?? '..',
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: user.name.isNotEmpty
                ? Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle2,
                  )
                : null,
            trailing: widget.contact.id == userProvider.getUser.id
                ? _displayButton(user, userProvider)
                : Container(height: 0, width: 0),
            onTap: () {
              List<User> userList = [];
              userList.add(user);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfilePage(
                          group: false,
                          contact: userList,
                          userProvider: widget.contact)));
            },
          );
        });
  }

  unfollowUser(User user, UserProvider userProvider) {
    _firebaseMethods.unfollowUser(
        currentUserId: userProvider.getUser.id, userId: widget.contact.id);
    setState(() {
      isFollowing = false;
    });
  }

  @override
  void initState() {
    _setupIsFollowing(widget.userProvider);
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

  filterBottomSheet() {
    return showModalBottomSheet(
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text('Filter', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 10),
              RadioListTile(
                value: null,
                groupValue: null,
                onChanged: (value) {},
                title: Text('From A-Z',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              RadioListTile(
                value: null,
                groupValue: null,
                onChanged: (value) {},
                title: Text('From newest',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              RadioListTile(
                value: null,
                groupValue: null,
                onChanged: (value) {},
                title: Text('From oldest',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ],
          );
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.getUser;
    print('Following: ${widget.contact.id}');
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text(
            'Following',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 100,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 16, 4, 16),
                      child: TextField(
                        controller: _searchController,
                        maxLines: 1,
                        autofocus: false,
                        textInputAction: TextInputAction.search,
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(
                          hintText: 'Search Following',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          prefixIcon: Icon(
                            Feather.search,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          isDense: true,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Feather.x,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                  ),
                                  onPressed: () => _clearSearch(),
                                )
                              : null,
                        ),
                        onSubmitted: (input) {
                          if (input.isNotEmpty) {
//                          _following = _firebaseMethods.searchFollowing(input);
                            query = input;
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Feather.filter,
                          color: Theme.of(context).primaryIconTheme.color),
                      onPressed: () => filterBottomSheet(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: query == null
                    ? StreamBuilder<QuerySnapshot>(
                        stream: _firebaseMethods.fetchFollowing(
                            userId: widget.contact.id, orderBy: 'addedOn'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.waiting ||
                              snapshot.connectionState ==
                                  ConnectionState.none) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.data.docs.length == 0) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                    child: Text(
                                        user.id ==
                                                Provider.of<UserProvider>(
                                                        context)
                                                    .getUser
                                                    .id
                                            ? 'You Are Not Following Anyone'
                                            : 'user is Not Following Anyone',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1)),
                                const SizedBox(height: 20),
                                TextButton.icon(
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => Home())),
                                    label: Text('Explore',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                    icon: Icon(
                                      Feather.compass,
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                    ))
                              ],
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (BuildContext context, int index) {
                              Follower following = Follower.fromMap(
                                  snapshot.data.docs[index].data());
                              return _buildFollowingTile(
                                  following, userProvider);
                            },
                            itemCount: snapshot.data.docs.length,
                          );
                        },
                      )
//                  : FutureBuilder(
//                      future: _following,
//                      builder: (context, snapshot) {
//                        if (!snapshot.hasData) {
//                          return Center(
//                            child: CircularProgressIndicator(),
//                          );
//                        } else if (snapshot.data.documents.length == 0) {
//                          return Center(
//                            child: Text('No users found',
//                                style: Theme.of(context).textTheme.bodyText1),
//                          );
//                        }
//                        return ListView.builder(
//                          itemBuilder: (BuildContext context, int index) {
//                            User user = User.fromMap(
//                                snapshot.data.data.documents[index]);
//                            return _buildSearchFollowingTile(user);
//                          },
//                          itemCount: snapshot.data.documents.length,
//                        );
//                      },
//                    ),
                    : buildFollowingSuggestions(query, userProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFollowingSuggestions(String query, UserProvider userProvider) {
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
        padding: EdgeInsets.symmetric(vertical: 20),
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          User searchUser = User(
              id: suggestionList[index].id,
              profileUrl: suggestionList[index].profileUrl,
              name: suggestionList[index].name,
              username: suggestionList[index].username);
          return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              onTap: () {
                List<User> userList = [];
                userList.add(searchUser);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfilePage(
                            contact: userList, userProvider: widget.contact)));
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: searchUser.profileUrl.isEmpty
                    ? AssetImage(imageNotAvailable)
                    : NetworkImage(searchUser.profileUrl),
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                searchUser.username,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: searchUser.name.isNotEmpty
                  ? Text(
                      searchUser.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  : null
              // trailing: !isFollowing
              //     ? FlatButton(onPressed: () {}, child: Text('+ Add'))
              //     : Container(),
              );
        });
  }
}

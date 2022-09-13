import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/follower.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';

class FollowersPage extends StatefulWidget {
  final User contact;
  final User userProvider;
  FollowersPage({this.contact, this.userProvider});
  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  TextEditingController _searchController = TextEditingController();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  List<User> userList;

  bool isFollowing;
  String query;
  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      query = '';
    });
  }

  _buildSearchFollowingTile(User user) {
    return ListTile(
      title: Text(user.username, style: Theme.of(context).textTheme.bodyText1),
      subtitle: Text(user.name, style: Theme.of(context).textTheme.subtitle1),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.transparent,
        backgroundImage: user.profileUrl.isEmpty
            ? AssetImage('assets/images/profile_place_holder.png')
            : CachedNetworkImageProvider(user.profileUrl),
      ),
      onTap: () {
        List<User> userList = [];
        userList.add(widget.contact);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              contact: userList,
            ),
          ),
        );
      },
    );
  }

  _setupIsFollowing(User userProvider) async {
    bool isFollowingUser = await _firebaseMethods.isFollowingUser(
        currentUserId: widget.contact.id, userId: userProvider.id);

    setState(() {
      isFollowing = isFollowingUser;
    });
  }

  Widget _displayButton(User user, UserProvider userProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            isFollowing
                ? ElevatedButton(
                    child: Text('Following'),
                    onPressed: () => unfollowUser(user, userProvider),
                    style: ElevatedButton.styleFrom(
                        textStyle: isFollowing
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyText1,
                        backgroundColor: Colors.green))
                : OutlinedButton(
                    child: Text('Follow'),
                    onPressed: () => followUser(user, userProvider),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    )),
          ],
        ),
      ],
    );
  }

  followingOptionSheet(User user, UserProvider userProvider) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                child: Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                      ),
                      Text(
                        '${user.username}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      IconButton(
                        icon: Icon(Feather.x,
                            color: Theme.of(context).primaryIconTheme.color),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                  onTap: isFollowing
                      ? () {
                          unfollowUser(user, userProvider);
                          Navigator.pop(context);
                        }
                      : () {
                          followUser(user, userProvider);
                          Navigator.pop(context);
                        },
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                      isFollowing ? Feather.user_x : Feather.user_plus,
                      color: Theme.of(context).primaryIconTheme.color),
                  title: Text(isFollowing ? 'Unfollow' : 'Follow',
                      style: Theme.of(context).textTheme.bodyText1)),
              ListTile(
                  onTap: () {
                    _firebaseMethods.unfollowUser(
                        currentUserId: user.id,
                        userId: userProvider.getUser.id);
                    setState(() {
                      isFollowing = false;
                    });
                    Navigator.pop(context);
                  },
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(Feather.user_minus,
                      color: Theme.of(context).primaryIconTheme.color),
                  title: Text('Remove',
                      style: Theme.of(context).textTheme.bodyText1)),
              ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return CustomDialog(
                            title: 'Block',
                            content: Text(
                              'Are you sure ${widget.contact.username} deserves to be blocked?',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            function: () {},
                            mainActionText: 'Never Want To See em',
                            secondaryActionText: 'Let me think about it',
                            function1: () => Navigator.pop(context),
                          );
                        });
                  },
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(Feather.slash, color: Colors.red),
                  title: Text('Block',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .apply(color: Colors.red))),
              SizedBox(height: 20),
            ],
          );
        });
  }

  _buildFollowerTile(Follower follower, UserProvider userProvider) {
    return FutureBuilder<User>(
        future: _authMethods.getUserWithId(follower.uid),
        builder: (context, snapshot) {
          User user = snapshot.data;
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: user.profileUrl != null
                  ? CachedNetworkImageProvider(user.profileUrl)
                  : CachedNetworkImageProvider(imageNotAvailable),
            ),
            title: Text(
              user?.username,
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
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    onPressed: () => followingOptionSheet(user, userProvider),
                  )
                : Container(
                    width: 20,
                  ),
            onTap: () {
              List<User> userList = [];
              userList.add(widget.contact.id == userProvider.getUser.id
                  ? userProvider.getUser
                  : user);

              widget.contact.id == userProvider.getUser.id
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(
                              group: false,
                              contact: userList,
                              userProvider: userProvider.getUser)))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(
                              group: false,
                              contact: userList,
                              userProvider: widget.contact)));
            },
            contentPadding: EdgeInsets.only(left: 20, top: 8, bottom: 8),
          );
        });
  }

  unfollowUser(User user, UserProvider userProvider) {
    _firebaseMethods.unfollowUser(
        currentUserId: userProvider.getUser.id, userId: user.id);
    setState(() {
      isFollowing = false;
    });
  }

  followUser(User user, UserProvider userProvider) {
    _firebaseMethods.followUser(
      currentUserId: userProvider.getUser.id,
      userId: user.id,
    );
    setState(() {
      isFollowing = true;
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Followers',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 100,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 4, 16),
                    child: TextField(
                      controller: _searchController,
                      maxLines: 1,
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      style: Theme.of(context).textTheme.bodyText1,
                      decoration: InputDecoration(
                          hintText: 'Search Followers',
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
                              : null),
                      onSubmitted: (input) {
                        if (input.isNotEmpty) {
//                          _followers = _firebaseMethods.searchFollowing(input);
                          query = input;
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(4, 16, 16, 16),
                        child: IconButton(
                          icon: Icon(Feather.filter,
                              color: Theme.of(context).primaryIconTheme.color),
                          onPressed: () => filterBottomSheet(),
                        ))),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: query == null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _firebaseMethods.fetchFollowers(
                          userId: widget.contact.id, orderBy: 'addedOn'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.data.docs.length == 0) {
                          return Center(
                              child: Text(
                                  widget.contact.id != userProvider.getUser.id
                                      ? '${widget.contact.username} has no followers'
                                      : 'You have no followers',
                                  style:
                                      Theme.of(context).textTheme.bodyText1));
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (BuildContext context, int index) {
                              Follower follower = Follower.fromMap(
                                  snapshot.data.docs[index].data());
                              return _buildFollowerTile(follower, userProvider);
                            },
                            itemCount: snapshot.data.docs.length,
                          );
                        }
                      },
                    )
//                  : FutureBuilder(
//                      future: _followers,
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
                  : buildFollowerSuggestions(query, userProvider),
            ),
          ),
        ],
      ),
    );
  }

  buildFollowerSuggestions(String query, UserProvider userProvider) {
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
              userList.add(widget.contact.id == userProvider.getUser.id
                  ? userProvider.getUser
                  : searchUser);

              widget.contact.id == userProvider.getUser.id
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(
                              contact: userList,
                              userProvider: userProvider.getUser)))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(
                              contact: userList,
                              userProvider: widget.contact)));
            },
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: searchUser.profileUrl == null
                  ? AssetImage(imageNotAvailable)
                  : NetworkImage(searchUser.profileUrl),
              backgroundColor: Colors.transparent,
            ),
            title: Text(
              searchUser?.username,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            subtitle: searchUser.name.isNotEmpty
                ? Text(
                    searchUser?.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                : null,
          );
        });
  }
}

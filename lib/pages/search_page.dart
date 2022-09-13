import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/messages_page.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';

class SearchPage extends StatefulWidget {
  final User userProvider;

  const SearchPage({Key key, this.userProvider}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  List<User> userList;
  List blockedUserList;
  Future<QuerySnapshot> _users;

  TextEditingController _searchController = TextEditingController();

  String query = '';

  @override
  void initState() {
    super.initState();

    _firebaseMethods.fetchAllUsers().then((List<User> list) {
      setState(() {
        userList = list;
      });
    });
  }

  bool userBlocked = false;

  _setupIsUserBlocked(User user, User userProvider) async {
    bool blockedUser = await _firebaseMethods.isUserBlocked(
        currentUserId: userProvider.id, userId: user.id);
    userBlocked = blockedUser;
  }

  @override
  void dispose() {
    // scrollController?.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: Container(
          padding: EdgeInsets.only(right: 20),
          alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 16),
                icon: Icon(Feather.arrow_left),
                onPressed: () {
                  clearSearch();
                  Navigator.pop(context);
                },
              ),
              Flexible(child: searchBox()),
            ],
          ),
        ),
      ),
      body: // : FutureBuilder(
          //     future: _users,
          //     builder: (context, searchSnapshot) {
          //       if (searchSnapshot.connectionState ==
          //           ConnectionState.waiting) {
          //         return Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       } else if (searchSnapshot.data.documents.length ==
          //           0) {
          //         return Center(
          //           child: Text(
          //             'No users found',
          //             style: Theme.of(context).textTheme.bodyText1,
          //           ),
          //         );
          //       }

          //       return ListView.builder(
          //         padding: EdgeInsets.symmetric(horizontal: 20),
          //         itemBuilder: (BuildContext context, int index) {
          //           User user = User.fromData(
          //               searchSnapshot.data.documents[index]);
          //           return _buildSearchSearchTile(user);
          //         },
          //         itemCount: searchSnapshot.data.documents.length,
          //       );
          //     },
          //   ),
          query.isEmpty
              ? Container()
              : buildSuggestions(query, widget.userProvider),
    );
  }

  void clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  Widget searchBox() {
    return TextFormField(
      style: Theme.of(context).textTheme.bodyText1,
      controller: _searchController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          setState(() {
            query = val;
//              _users = _firebaseMethods.searchUser(val);
          });
        }
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search..',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () => clearSearch(),
                icon: Icon(Feather.x,
                    color: Theme.of(context).primaryIconTheme.color),
              )
            : IconButton(
                icon: Icon(FontAwesome.qrcode,
                    color: Theme.of(context).primaryIconTheme.color),
                onPressed: () {},
              ),
        isDense: true,
        prefixIcon: Icon(Feather.search,
            color: Theme.of(context).primaryIconTheme.color),
      ),
    );
  }

  _buildSearchSearchTile(User user) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10),
      title: Text(user.username, style: Theme.of(context).textTheme.bodyText1),
      subtitle: Text(user.name, style: Theme.of(context).textTheme.bodyText1),
      leading: GestureDetector(
        // onTap: () => Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MessagesPage(
        //       userId: user.id,
        //       currentUserId: Provider.of<UserData>(context).currentUserId,
        //     ),
        //   ),
        // ),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.15),
          backgroundImage: user.profileUrl.isNotEmpty
              ? CachedNetworkImageProvider(user.profileUrl)
              : null,
        ),
      ),
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => MessagesPage(
      //       receiver: searchUser,
      //     ),
      //   ),
      // ),
    );
  }

  buildSuggestions(String query, User userProvider) {
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

          return FutureBuilder<bool>(
              future: _firebaseMethods.isUserBlocked(
                  currentUserId: searchUser.id, userId: userProvider.id),
              builder: (context, snapshot) {
                final youBlocked = snapshot.data;
                if (!snapshot.hasData) {
                  return ProfileShimmer();
                }
                if (youBlocked) {
                  return Container();
                } else {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    onTap: userProvider.id == searchUser.id
                        ? () {
                            List<User> userList = [];
                            userList.add(searchUser);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfilePage(
                                        contact: userList,
                                        group: false,
                                        userProvider: userProvider)));
                          }
                        : () {
                            print('THIS IS SEARCHED USER ${searchUser.id}');
                            List<User> messageUserList = [];
                            messageUserList.add(searchUser);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => MessagesPage(
                                        receivers: messageUserList,
                                        group: false,
                                        userProvider: widget.userProvider)));
                          },
                    leading: GestureDetector(
                      onTap: () {
                        List<User> userList = [];
                        userList.add(searchUser);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfilePage(
                                    contact: userList,
                                    group: false,
                                    userProvider: userProvider)));
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: searchUser.profileUrl.isEmpty
                            ? AssetImage(
                                'assets/images/profile_place_holder.png')
                            : NetworkImage(searchUser.profileUrl),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    title: Text(
                      searchUser.username,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Text(
                      searchUser.name,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    // trailing: !isFollowing
                    //     ? FlatButton(onPressed: () {}, child: Text('+ Add'))
                    //     : Container(),
                  );
                }
              });
        });
  }
}

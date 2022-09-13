import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/answer_layout.dart';
import 'package:howl/pages/new_chat_page.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:howl/widgets/last_message.dart';
import 'package:howl/widgets/last_message_time.dart';
import 'package:howl/widgets/online_indicator.dart';
import 'package:provider/provider.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/models/chat.dart';
import 'messages_page.dart';

class ChatsPage extends StatefulWidget {
  final Function jumpToCamera;
  ChatsPage({this.jumpToCamera});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  bool newStory = true;
  bool hideStories = false;
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return AnswerLayout(
        scaffold: Scaffold(
            floatingActionButton: floatingAction(userProvider),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _firebaseMethods.fetchChats(
                          userId: userProvider.getUser.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              LinearProgressIndicator(),
                            ],
                          );
                        }
                        if (snapshot.data.docs.length == 0) {
                          return Center(
                            child: Text('No Conversation Yet',
                                style: Theme.of(context).textTheme.bodyText1),
                          );
                        }
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(top: 24),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              Chat chat = Chat.fromMap(
                                  snapshot.data.docs[index].data());

                              return chatListItem(chat, userProvider);
                            });
                      }),
                ),
              ],
            )));
  }

  Widget chatListItem(Chat chat, UserProvider userProvider) {
    var groupList = chat.members;
    groupList.keys;
    print(groupList);

    return FutureBuilder<List<User>>(
        future: _authMethods.getUsersWithId(groupList.keys.toList()),
        builder: (context, snapshot) {
          List<User> user = snapshot.data;
          if (!snapshot.hasData) {
            return ProfileShimmer();
          }
          return chat.blocked
              ? Container()
              : ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MessagesPage(
                                  userProvider: userProvider.getUser,
                                  receivers: user,
                                  group: chat.group ? true : false,
                                  chat: chat,
                                )));
                  },
                  onLongPress: () =>
                      chatLongPressSheet(groupList, user, userProvider, chat),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    chat.group
                                        ? chat.groupName
                                        : user
                                            .firstWhere((element) =>
                                                element.username !=
                                                userProvider.getUser.username)
                                            .username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .apply(fontSizeFactor: 1.3)),
                                SizedBox(width: 6),
                                chat.muted
                                    ? Icon(Feather.volume_x,
                                        size: 18,
                                        color: Theme.of(context)
                                            .primaryIconTheme
                                            .color)
                                    : Container(height: 0, width: 0),
                              ],
                            ),
                          ]),
                    ],
                  ),
                  subtitle: chat.receiversTyping.containsValue(true)
                      ? Text('Typing...',
                          style: Theme.of(context).textTheme.bodyText1.apply(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .color
                                  .withOpacity(0.7)))
                      : LastMessage(
                          stream: _firebaseMethods.fetchLastMessage(
                              currentUserId: userProvider.getUser.id,
                              userId: groupList.keys.toList()),
                        ),
                  trailing: LastMessageTime(
                      stream: _firebaseMethods.fetchLastMessage(
                    currentUserId: userProvider.getUser.id,
                    userId: groupList.keys.toList(),
                  )),
                  leading: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: chat.group
                        ? CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Wrap(children: [
                              for (var us = 0; us < user.length; us++)
                                CircleAvatar(
                                    radius: 10,
                                    backgroundImage: CachedNetworkImageProvider(
                                        user[us].profileUrl))
                            ]),
                          )
                        : Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: user.last.profileUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(user
                                        .firstWhere((element) =>
                                            element.profileUrl !=
                                            userProvider.getUser.profileUrl)
                                        .profileUrl)
                                    : CachedNetworkImageProvider(
                                        imageNotAvailable),
                              ),
                              Positioned(
                                  bottom: 5,
                                  right: 25,
                                  child: OnlineIndic(
                                      height: 10,
                                      uid: user
                                          .firstWhere((element) =>
                                              element.id !=
                                              userProvider.getUser.id)
                                          .id))
                            ],
                          ),
                  ),
                );
        });
  }

  // storyView() {
  // return  AnimatedOpacity(
  //   duration: Duration(milliseconds: 100),
  //   opacity: hideStories ? 0 : 1,
  //   child: Container(
  //     alignment: Alignment.topCenter,
  //     margin: EdgeInsets.symmetric(
  //       vertical: 20,
  //     ),
  //     width: MediaQuery.of(context).size.width,
  //     height: hideStories
  //         ? 0
  //         : MediaQuery.of(context).size.height * 0.12,
  //     child: ListView.builder(
  //         padding: EdgeInsets.symmetric(horizontal: 20),
  //         physics: BouncingScrollPhysics(),
  //         scrollDirection: Axis.horizontal,
  //         itemCount: 10,
  //         itemBuilder: (context, index) {
  //           return FittedBox(
  //             fit: BoxFit.fill,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 GestureDetector(
  //                   onLongPress: () => storyLongPressDialog(),
  //                   child: Container(
  //                     child: Stack(
  //                       children: [
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             shape: BoxShape.circle,
  //                             border: Border.all(
  //                                 color: newStory
  //                                     ? Theme.of(context)
  //                                         .accentColor
  //                                     : Theme.of(context)
  //                                         .accentColor
  //                                         .withOpacity(0.2),
  //                                 width: 0.5),
  //                           ),
  //                           padding: EdgeInsets.all(3),
  //                           child: CircleAvatar(
  //                               maxRadius: 16,
  //                               backgroundColor:
  //                                   Theme.of(context)
  //                                       .accentColor
  //                                       .withOpacity(0.15)),
  //                         ),
  //                         Positioned(
  //                             bottom: 10,
  //                             left: 0,
  //                             child: Variables.onlineCircle(
  //                                 6.5)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(4),
  //                   child: Text(
  //                     'Username',
  //                     style: TextStyle(
  //                         color: Theme.of(context)
  //                             .textTheme
  //                             .subtitle2
  //                             .color,
  //                         fontSize: 8),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }),
  //   ),
  // ),
  // }

  storyLongPressDialog() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Username', style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 10),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text('View Profile',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text('Mute Story',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  chatLongPressSheet(
      Map groupList, List<User> user, UserProvider userProvider, Chat chat) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          String groupId = groupList.keys.toList().toString();
          user.removeWhere((element) => element.id == userProvider.getUser.id);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        chat.group ? chat.groupName : user.single.username,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Feather.video,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(chat.group ? 'Group Video Call' : 'Video Call',
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Feather.phone,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(chat.group ? 'Group Call' : 'Call',
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      chat.muted ? Feather.volume_x : Feather.volume,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(chat.muted ? 'Unmute' : 'Mute',
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      if (chat.muted) {
                        print(groupId);
                        _firebaseMethods.unmuteChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      } else {
                        print(groupId);
                        _firebaseMethods.muteChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Feather.archive,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(chat.archived ? 'Unarchive' : 'Archive',
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      if (!chat.archived) {
                        _firebaseMethods.archiveChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      } else {
                        _firebaseMethods.archiveChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Feather.lock,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(chat.locked ? 'Unlock' : 'Lock',
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      if (chat.locked) {
                        _firebaseMethods.unlockChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      } else {
                        _firebaseMethods.lockChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Feather.paperclip,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(chat.pinned ? 'Unpin' : 'Pin',
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      if (chat.pinned) {
                        _firebaseMethods.unpinChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      } else {
                        _firebaseMethods.pinChat(
                            userProvider.getUser.id, groupId);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  chat.group
                      ? ListTile(
                          leading: Icon(
                            Feather.log_out,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          title: Text('Leave Group',
                              style: Theme.of(context).textTheme.bodyText1),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return CustomDialog(
                                    title: 'Leave Group',
                                    content: Text(
                                        'Do you want to group of ${user.first.username}?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                    mainActionText: 'Leave',
                                    function: () {
                                      Navigator.pop(context);
                                      _firebaseMethods.deleteChat(
                                          userProvider.getUser.id, groupId);
                                    },
                                    secondaryActionText: 'Stay',
                                    function1: () => Navigator.pop(context),
                                  );
                                });
                          },
                        )
                      : Container(),
                  ListTile(
                    leading: Icon(Feather.trash_2, color: Colors.redAccent),
                    title: Text('Delete',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .apply(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              title: 'Delete Conversation',
                              content: Text(
                                  'Do you want to delete the conversation of ${user.first.username}',
                                  style: Theme.of(context).textTheme.bodyText1),
                              mainActionText: 'Delete',
                              function: () {
                                Navigator.pop(context);
                                _firebaseMethods.deleteChat(
                                    userProvider.getUser.id, groupId);
                              },
                              secondaryActionText: 'Keep Them',
                              function1: () => Navigator.pop(context),
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget floatingAction(UserProvider userProvider) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) {
              return NewChatPage(contact: userProvider.getUser);
            });
      },
      label: Text('Message',
          style: Theme.of(context).textTheme.button.apply(
              color: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .color
                  .withOpacity(0.8))),
      icon: Icon(
        Feather.edit,
        color: Theme.of(context).accentIconTheme.color.withOpacity(0.8),
      ),
    );
  }
}

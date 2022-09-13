import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_show_more/flutter_show_more.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/chat.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/edit_profile.dart';
import 'package:howl/pages/followers_page.dart';
import 'package:howl/pages/following_page.dart';
import 'package:howl/pages/messages_page.dart';
import 'package:howl/pages/requests_page.dart';
import 'package:howl/pages/settings.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/theme/app_theme.dart';
import 'package:howl/theme/theme_types.dart';
import 'package:howl/utils/call_utils.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/utils/permissions.dart';
import 'package:howl/utils/utilities.dart';
import 'package:howl/widgets/cached_image.dart';
import 'package:howl/widgets/circle_options.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:howl/widgets/last_request.dart';
import 'package:howl/widgets/online_indicator.dart';
import 'package:howl/widgets/user_circle.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'answer_layout.dart';

class ProfilePage extends StatefulWidget {
  final Function jumpToFollowers;
  final Function jumpToFollowing;
  final List<User> contact;
  final bool group;
  final Chat chat;
  final User userProvider;

  ProfilePage(
      {this.jumpToFollowers,
      this.jumpToFollowing,
      this.contact,
      this.userProvider,
      this.group,
      this.chat});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  AuthMethods _authMethods = AuthMethods();
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  bool isFollowing = false;
  bool isRequestSent = false;
  bool isRequest = false;
  bool youFollowing = false;
  int followingCount;
  int followerCount;
  int requestCount;
  bool isOnline = false;

  int selectedNotifications = 0;

  bool messageOptionOpen = false;

  bool isUserBlocked = false;

  bool isYouBlocked = false;

  String groupName;

  bool updatingGroupName = false;

  final groupNameKey = GlobalKey<FormState>();
  onGroupNameSave() async {
    if (groupNameKey.currentState.validate()) {
      groupNameKey.currentState.save();
      setState(() {
        updatingGroupName = true;
      });
      List<String> userIds = [];
      for (var us = 0; us < widget.contact.length; us++) {
        userIds.add(widget.contact[us].id);
      }
      await _firebaseMethods
          .updateGroupName(widget.userProvider.id, userIds, groupName)
          .then((value) {
        setState(() {
          widget.chat.groupName = groupName;
          updatingGroupName = false;
        });
        Navigator.pop(context);
      });
      print(groupName);
    }
    setState(() {
      updatingGroupName = false;
    });
  }

  @override
  void initState() {
    if (!widget.group) {
      setupIsFollowing(widget.userProvider);
      setupIsRequestSent(widget.userProvider);
      setupIsRequestReceived(widget.userProvider);
      setupFollowingYou(widget.userProvider);
      setupIsBlocked(widget.userProvider);
      setupIsYouBlocked(widget.userProvider);
      _setupFollowers();
      _setupFollowing();
      _setupRequestsNum();
    }
    super.initState();
  }

//if you're following user
  setupIsFollowing(User userProvider) async {
    // if (widget.contact.length == 1) {
    bool isFollowingUser = await _firebaseMethods.isFollowingUser(
        currentUserId: widget.userProvider.id, userId: widget.contact.first.id);

    setState(() {
      isFollowing = isFollowingUser;
    });
    // } else {
    //   bool isFollowingUser = await _firebaseMethods.isFollowingUser(
    //       currentUserId: widget.userProvider.id,
    //       userId: widget.contact
    //           .first
    //           .id);

    //   setState(() {
    //     isFollowing = isFollowingUser;
    //   });
    // }
  }

  //if user is following you
  setupFollowingYou(User userProvider) async {
    // if (widget.contact.length == 1) {
    bool youFollowingUser = await _firebaseMethods.isFollowingUser(
        currentUserId: widget.contact.first.id, userId: widget.userProvider.id);

    setState(() {
      youFollowing = youFollowingUser;
    });
    // } else {
    //   bool youFollowingUser = await _firebaseMethods.isFollowingUser(
    //       currentUserId: widget.contact
    //           .firstWhere((element) => element.id != widget.userProvider.id)
    //           .id,
    //       userId: widget.userProvider.id);

    //   setState(() {
    //     youFollowing = youFollowingUser;
    //   });
    // }
  }

  setupIsRequestSent(User userProvider) async {
    // if (widget.contact.length == 1) {
    bool requestSent = await _firebaseMethods.isRequest(
        currentUserId: widget.userProvider.id, userId: widget.contact.first.id);

    setState(() {
      isRequestSent = requestSent;
      print(isRequestSent.toString());
    });
    // } else {
    //   bool requestSent = await _firebaseMethods.isRequest(
    //       currentUserId: widget.userProvider.id,
    //       userId: widget.contact
    //           .firstWhere((element) => element.id != widget.userProvider.id)
    //           .id);

    //   setState(() {
    //     isRequestSent = requestSent;
    //     print(isRequestSent.toString());
    //   });
    // }
  }

  setupIsRequestReceived(User userProvider) async {
    // if (widget.contact.length == 1) {
    bool requestReceived = await _firebaseMethods.isRequestReceived(
      currentUserId: widget.userProvider.id,
      userId: widget.contact.first.id,
    );
    setState(() {
      isRequest = requestReceived;
      print(isRequest.toString());
    });
    // } else {
    //   bool requestReceived = await _firebaseMethods.isRequestReceived(
    //     currentUserId: widget.userProvider.id,
    //     userId: widget.contact
    //         .firstWhere((element) => element.id != widget.userProvider.id)
    //         .id,
    //   );
    //   setState(() {
    //     isRequest = requestReceived;
    //     print(isRequest.toString());
    //   });
    // }
  }

  setupIsBlocked(User userProvider) async {
    // if (widget.contact.length > 1) {
    //   bool userBlocked = await _firebaseMethods.isUserBlocked(
    //     currentUserId: widget.userProvider.id,
    //     userId: widget.contact
    //         .firstWhere((element) => element.id != widget.userProvider.id)
    //         .id,
    //   );
    //   setState(() {
    //     isUserBlocked = userBlocked;
    //   });
    // } else {
    bool userBlocked = await _firebaseMethods.isUserBlocked(
      currentUserId: widget.userProvider.id,
      userId: widget.contact.first.id,
    );
    setState(() {
      isUserBlocked = userBlocked;
    });
    // }
  }

  setupIsYouBlocked(User userProvider) async {
    // if (widget.contact.length > 1) {
    //   bool youBlocked = await _firebaseMethods.isUserBlocked(
    //     currentUserId: widget.contact
    //         .firstWhere((element) => element.id != widget.userProvider.id)
    //         .id,
    //     userId: widget.userProvider.id,
    //   );
    //   setState(() {
    //     isYouBlocked = youBlocked;
    //   });
    // } else {
    bool youBlocked = await _firebaseMethods.isUserBlocked(
      currentUserId: widget.contact.first.id,
      userId: widget.userProvider.id,
    );
    setState(() {
      isYouBlocked = youBlocked;
    });
    // }
  }

  _setupFollowers() async {
    // if (widget.contact.length == 1) {
    int userFollowerCount =
        await _firebaseMethods.numFollowers(widget.contact.first.id);
    setState(() {
      followerCount = userFollowerCount;
    });
    // } else {
    //   int userFollowerCount = await _firebaseMethods.numFollowers(widget.contact
    //       .firstWhere((element) => element.id != widget.userProvider.id)
    //       .id);
    //   setState(() {
    //     followerCount = userFollowerCount;
    //   });
    // }
  }

  _setupRequestsNum() async {
    // if (widget.contact.length == 1) {
    int requestsCount =
        await _firebaseMethods.receiverRequestsNum(widget.contact.first.id);
    setState(() {
      requestCount = requestsCount;
    });
    // } else {
    //   int requestsCount = await _firebaseMethods.receiverRequestsNum(widget
    //       .contact
    //       .firstWhere((element) => element.id != widget.userProvider.id)
    //       .id);
    //   setState(() {
    //     requestCount = requestsCount;
    //   });
    // }
  }

  _setupFollowing() async {
    // if (widget.contact.length == 1) {
    int userFollowingCount =
        await _firebaseMethods.numFollowing(widget.contact.first.id);
    setState(() {
      followingCount = userFollowingCount;
    });
    // } else {
    //   int userFollowingCount = await _firebaseMethods.numFollowing(widget
    //       .contact
    //       .firstWhere((element) => element.id != widget.userProvider.id)
    //       .id);
    //   setState(() {
    //     followingCount = userFollowingCount;
    //   });
    // }
  }

  unfollowUser(User userProvider) {
    if (widget.contact.first.private == true) {
      return showModalBottomSheet(
          context: context,
          builder: (context) {
            return CustomDialog(
              title: 'Unfollow ${widget.contact.first.username}',
              content: Text(
                'Are you sure you want to unfollow this user?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              mainActionText: 'Unfollow',
              secondaryActionText: 'Keep Them',
              function: () {
                setState(() {
                  isFollowing = false;
                  followerCount--;
                });
                _firebaseMethods.unfollowUser(
                    currentUserId: userProvider.id,
                    userId: widget.contact.first.id);
                Navigator.pop(context);
              },
              function1: () => Navigator.pop(context),
            );
          });
    } else {
      setState(() {
        isFollowing = false;
        followerCount--;
      });
      _firebaseMethods.unfollowUser(
          currentUserId: userProvider.id, userId: widget.contact.first.id);
    }
  }

  followUser(User userProvider) {
    if (widget.contact.first.private == true) {
      setState(() {
        isRequestSent = true;
      });
      _firebaseMethods.sendRequest(
          currentUserId: userProvider.id, userId: widget.contact.first.id);
    } else {
      print(widget.contact.first.private.toString);
      setState(() {
        isFollowing = true;
        followerCount++;
      });
      _firebaseMethods.followUser(
          currentUserId: userProvider.id, userId: widget.contact.first.id);
    }
  }

  Widget _listTileIcon(IconData icon) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          icon,
          color: Theme.of(context).primaryIconTheme.color,
        ),
      );

  Widget _displayMessageButton(User user, User userProvider) {
    if (widget.contact.first.id == userProvider.id) {
      return Container();
    } else {
      if (isUserBlocked) {
        return Container();
      } else {
        if (messageOptionOpen) {
          return CircleOptions(
            size: 32,
            padding: EdgeInsets.zero,
            color: Theme.of(context).accentColor,
            icon: Feather.video,
            icon2: Feather.message_circle,
            iconSize: 14,
            iconColor: Theme.of(context).accentIconTheme.color,
            function: () {
              setState(() {
                messageOptionOpen = false;
              });
            },
            function1: () async {
              setState(() {
                messageOptionOpen = false;
              });
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: widget.userProvider,
                      to: widget.contact.first,
                      context: context)
                  : showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: 'Oppss',
                          content: Text(
                              'You need to open settings and grant the app permission to the device camera and microphone',
                              style: Theme.of(context).textTheme.bodyText1),
                          mainActionText: 'Open Settings',
                          function: () => PhotoManager.openSetting(),
                          secondaryActionText: 'Cancel',
                          function1: () {
                            Navigator.pop(context);
                          },
                        );
                      });
            },
            function2: () {
              List<User> messageList;
              messageList.add(widget.contact.first);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MessagesPage(
                      receivers: messageList,
                    ),
                  ));
            },
          );
        }
        return GestureDetector(
          onTap: () {
            setState(() {
              messageOptionOpen = true;
            });
          },
          child: Variables.circleIcon(
              32,
              Theme.of(context).accentColor,
              Theme.of(context).accentIconTheme.color,
              Feather.message_circle,
              14,
              EdgeInsets.all(8)),
        );
      }
    }
  }

  Widget _displayButton(User user, User userProvider) {
    if (widget.contact.first.id == userProvider.id) {
      return IconButton(
        onPressed: () {
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditProfilePage(user: widget.userProvider)),
          );
        },
        icon: Icon(Feather.edit_2,
            color: Theme.of(context).primaryIconTheme.color),
      );
    } else {
      if (isFollowing) {
        return IconButton(
          tooltip: 'Unfollow',
          onPressed: () => unfollowUser(userProvider),
          icon: Icon(Feather.user_check,
              color: Theme.of(context).primaryIconTheme.color),
        );
      } else if (isUserBlocked) {
        return Container();
      } else if (isYouBlocked) {
        return Container();
      } else if (isRequestSent) {
        return IconButton(
          tooltip: 'Cancel Request',
          onPressed: () async {
            await _firebaseMethods.deleteRequest(
                currentUserId: userProvider.id,
                userId: widget.contact.first.id);
            setState(() {
              isRequestSent = false;
            });
          },
          icon: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Icon(Feather.user,
                  color: Theme.of(context).primaryIconTheme.color),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Feather.arrow_right,
                  size: 13, color: Theme.of(context).primaryIconTheme.color),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Feather.arrow_right,
                  size: 13, color: Theme.of(context).primaryIconTheme.color),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Feather.arrow_right,
                  size: 13, color: Theme.of(context).primaryIconTheme.color),
            ),
          ]),
        );
      } else if (isRequest && widget.contact.first.id != userProvider.id) {
        return Container();
      } else {
        return IconButton(
          onPressed: () {
            followUser(userProvider);
          },
          icon: Icon(Feather.user_plus,
              color: Theme.of(context).primaryIconTheme.color),
        );
      }
    }
  }

  Widget _displayNotificationButton(User user, User userProvider) {
    if (widget.contact.first.id == userProvider.id) {
      return IconButton(
        icon: Icon(
          Feather.bell,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestsPages(),
          ),
        ),
      );
    } else {
      return IconButton(
        icon: Icon(
          Feather.share_2,
        ),
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) {
              return CustomDialog();
            }),
      );
    }
  }

  themeDialog(AppTheme appTheme) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Themes',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),
              Container(
                decoration: appTheme.useSystem
                    ? BoxDecoration(
                        color: Theme.of(context).accentColor.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            topRight: Radius.circular(25)))
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Column(
                    children: [
                      Icon(
                        Feather.sun,
                        size: 15,
                        semanticLabel: 'System Theme',
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      Icon(
                        Feather.moon,
                        semanticLabel: 'System Theme',
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                    ],
                  ),
                  title: Text('System',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .setUseSystem(true);
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                decoration: (appTheme.themeType == ThemeType.LIGHT &&
                        !appTheme.useSystem)
                    ? BoxDecoration(
                        color: Theme.of(context).accentColor.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            topRight: Radius.circular(25)))
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Feather.sun,
                    color: Theme.of(context).primaryIconTheme.color,
                    semanticLabel: 'Light Theme',
                  ),
                  title: Text('Light',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .setThemeType(ThemeType.LIGHT);
                    Provider.of<AppTheme>(context, listen: false)
                        .setUseSystem(false);
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                decoration: (appTheme.themeType == ThemeType.DARK &&
                        !appTheme.useSystem)
                    ? BoxDecoration(
                        color: Theme.of(context).accentColor.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            topRight: Radius.circular(25)))
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Feather.moon,
                    semanticLabel: 'Dark Theme',
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                  title: Text('Dark',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .setThemeType(ThemeType.DARK);
                    Provider.of<AppTheme>(context, listen: false)
                        .setUseSystem(false);
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                decoration: (appTheme.themeType == ThemeType.MIDNIGHT &&
                        !appTheme.useSystem)
                    ? BoxDecoration(
                        color: Theme.of(context).accentColor.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            topRight: Radius.circular(25)))
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Feather.circle,
                    color: Theme.of(context).primaryIconTheme.color,
                    semanticLabel: 'Midnight Theme',
                  ),
                  title: Text('Midnight',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .setThemeType(ThemeType.MIDNIGHT);
                    Provider.of<AppTheme>(context, listen: false)
                        .setUseSystem(false);
                    Navigator.pop(context);
                  },
                ),
              ),
            ]),
          );
        });
  }

  notificationDialog(User userProvider) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Notifications',
                    style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Feather.star,
                    semanticLabel: 'Prioritize Notifications',
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                  title: Text('Prioritize Notifications',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () => _firebaseMethods.userNotifications(
                      userProvider.id, widget.contact.first.id, 'priority'),
                  selected: selectedNotifications == 0 ? true : false,
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Feather.bell,
                    color: Theme.of(context).primaryIconTheme.color,
                    semanticLabel: 'Normal',
                  ),
                  title: Text('Normal',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    _firebaseMethods.userNotifications(
                        userProvider.id, widget.contact.first.id, 'normal');
                    Navigator.pop(context);
                    setState(() {
                      selectedNotifications = 1;
                    });
                  },
                  selected: selectedNotifications == 1 ? true : false,
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Feather.bell_off,
                    color: Theme.of(context).primaryIconTheme.color,
                    semanticLabel: 'Mute',
                  ),
                  title: Text('Mute',
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () {
                    _firebaseMethods.userNotifications(
                        userProvider.id, widget.contact.first.id, 'muted');
                    Navigator.pop(context);
                    setState(() {
                      selectedNotifications = 2;
                    });
                  },
                  selected: selectedNotifications == 2 ? true : false,
                ),
              ],
            ),
          );
        });
  }

  Widget _displayFollowBack(User userProvider) {
    if (!isFollowing && youFollowing) {
      print('IS FOLLOWING ${isFollowing.toString()}');
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10)),
          color: Theme.of(context).accentColor.withOpacity(0.4),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text('${widget.contact.first.username} follows you',
                    style: Theme.of(context).textTheme.bodyText2,
                    overflow: TextOverflow.visible,
                    softWrap: true),
              ),
              SizedBox(height: 20),
              TextButton.icon(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).accentColor.withOpacity(0.4)),
                  label: Text('Follow Back',
                      style: Theme.of(context).textTheme.bodyText2),
                  icon: isRequestSent
                      ? Icon(Feather.arrow_right,
                          size: 20,
                          color: Theme.of(context).accentIconTheme.color)
                      : Icon(Feather.user_plus,
                          size: 20,
                          color: Theme.of(context).accentIconTheme.color),
                  onPressed: () {
                    _firebaseMethods.followUser(
                        currentUserId: userProvider.id,
                        userId: widget.contact.first.id);
                    setState(() {
                      isRequest = false;
                      followerCount++;
                    });
                  }),
            ]),
      );
    }
    return Container();
  }

  Widget _displayAcceptOrRefuseRequest(User userProvider) {
    if (isRequest && widget.contact.first.id != userProvider.id) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10)),
          color: Theme.of(context).accentColor.withOpacity(0.4),
        ),
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${widget.contact.first.id} requested to follow you',
                  style: Theme.of(context).textTheme.bodyText2,
                  overflow: TextOverflow.visible,
                  softWrap: true),
              SizedBox(height: 20),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).accentColor.withOpacity(0.4)),
                      label: Text('Accept',
                          style: Theme.of(context).textTheme.bodyText2),
                      icon: Icon(Feather.check,
                          color: Theme.of(context).accentIconTheme.color),
                      onPressed: () {
                        _firebaseMethods.deleteRequest(
                            currentUserId: widget.contact.first.id,
                            userId: userProvider.id);
                        _firebaseMethods.followUser(
                            currentUserId: widget.contact.first.id,
                            userId: userProvider.id);
                        setState(() {
                          isRequest = false;
                          followerCount++;
                        });
                      }),
                  const SizedBox(width: 20),
                  TextButton.icon(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).accentColor.withOpacity(0.4)),
                      label: Text('Decline',
                          style: Theme.of(context).textTheme.bodyText2),
                      icon: Icon(Feather.x,
                          color: Theme.of(context).accentIconTheme.color),
                      onPressed: () {
                        _firebaseMethods.deleteRequest(
                            currentUserId: widget.contact.first.id,
                            userId: userProvider.id);
                        setState(() {
                          isRequest = false;
                        });
                      }),
                ],
              ))
            ]),
      );
    }

    return Container();
  }

  Widget sharedMedia(User userProvider) {
    if (widget.contact.first.id == userProvider.id) {
      return Container();
    } else if (isUserBlocked || isYouBlocked) {
      return Container();
    } else {
      return Column(
        children: [
          const Divider(
            endIndent: 20,
            indent: 20,
            thickness: 0.5,
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 220,
            child: Stack(
              children: [
                Align(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Card(
                          elevation: 3,
                          child: Container(
                            height: 150,
                            width: 140,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Feather.image,
                                color:
                                    Theme.of(context).primaryIconTheme.color),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 30,
                  bottom: 45,
                  child: Card(
                    elevation: 10,
                    color: Theme.of(context).accentColor,
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('10',
                                style: Theme.of(context).textTheme.bodyText2),
                            const SizedBox(height: 10),
                            Text('Media',
                                style: Theme.of(context).textTheme.bodyText2),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  settingsSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Settings(user: widget.userProvider);
        });
  }

  Widget _displaySettingList(AppTheme appTheme, User userProvider) {
    if (widget.contact.first.id == userProvider.id) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              'Themes',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            leading: _listTileIcon(Feather.sun),
            subtitle: Text(
              appTheme.useSystem
                  ? 'Auto'
                  : appTheme.themeType == ThemeType.LIGHT
                      ? 'Light'
                      : appTheme.themeType == ThemeType.DARK
                          ? 'Dark'
                          : appTheme.themeType == ThemeType.MIDNIGHT
                              ? 'Midnight'
                              : 'Select a Theme',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () => themeDialog(appTheme),
          ),
          ListTile(
            leading: _listTileIcon(Feather.log_out),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              showModalBottomSheet(
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: 'Logout',
                      content: Text(
                        'Are you sure you want to logout?',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      function: () {
                        _authMethods.signOut();
                        Navigator.pop(context);
                      },
                      mainActionText: 'Yes',
                      secondaryActionText: 'No',
                      function1: () => Navigator.pop(context),
                    );
                  },
                  context: context);
            },
            enabled: true,
          ),
        ],
      );
    } else {
      if (isUserBlocked || isYouBlocked) {
        return Container();
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Options',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
            ListTile(
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              leading: _listTileIcon(
                selectedNotifications == 2 ? Feather.bell_off : Feather.bell,
              ),
              subtitle: Text(
                selectedNotifications == 0
                    ? 'Active'
                    : selectedNotifications == 1
                        ? 'Only Media'
                        : selectedNotifications == 2
                            ? 'None'
                            : '',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () => notificationDialog(userProvider),
            ),
            if (widget.group)
              ListTile(
                leading: _listTileIcon(Feather.edit_3),
                title: Text('Change name',
                    style: Theme.of(context).textTheme.bodyText1),
                subtitle: Text(widget.chat.groupName,
                    style: Theme.of(context).textTheme.bodyText1),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: groupNameKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text('Change name',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  initialValue: widget.chat.groupName.isNotEmpty
                                      ? widget.chat.groupName
                                      : null,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Group name',
                                    labelText: 'Group name',
                                  ),
                                  validator: (value) => value.isEmpty
                                      ? 'Group name must not be empty'
                                      : null,
                                  onSaved: (value) {
                                    groupName = value;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).accentColor),
                                  onPressed: () {
                                    setState(() {
                                      updatingGroupName = true;
                                    });
                                    onGroupNameSave();
                                  },
                                  child: updatingGroupName
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 20),
                                          child: CircularProgressIndicator(
                                              strokeWidth: 0.5,
                                              backgroundColor: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .color),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 20),
                                          child: Text('Change Name',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
              )
            else
              ListTile(
                leading: _listTileIcon(
                  Feather.toggle_left,
                ),
                title: Text(
                  'Restrict',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onTap: () => {},
                enabled: true,
              ),
            ListTile(
              leading: _listTileIcon(Feather.alert_octagon),
              title: Text(
                'Report',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
              enabled: true,
            ),
            widget.group
                ? ListTile(
                    title: Text(
                      'Leave Group',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    leading: _listTileIcon(Feather.log_out),
                    onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CustomDialog(
                            title: 'Leave Group',
                            content: Text(
                              'Are you sure to leave ${widget.chat.groupName} group?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            function: () {
                              Navigator.pop(context);
                              Flushbar(
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  message: 'Left group');
                            },
                            mainActionText: 'Leave',
                            secondaryActionText: 'Cancel',
                            function1: () => Navigator.pop(context),
                          );
                        }),
                  )
                : Container(),
            widget.group
                ? ListTile(
                    title: Text(
                      'Delete Group',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    leading: _listTileIcon(Feather.trash),
                    onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CustomDialog(
                            title: 'Delete Group',
                            content: Text(
                              'Data for this group will be permanently deleted',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            function: () {
                              Navigator.pop(context);
                              Flushbar(
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  message: 'Group deleted');
                            },
                            mainActionText: 'Delete',
                            secondaryActionText: 'Cancel',
                            function1: () => Navigator.pop(context),
                          );
                        }),
                  )
                : ListTile(
                    title: Text(
                      'Block',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    leading: _listTileIcon(Feather.slash),
                    onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CustomDialog(
                            title: 'Block',
                            content: Text(
                              'Are you sure ${widget.contact.first.username} deserves to be blocked?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            function: () async {
                              await _firebaseMethods
                                  .blockUser(
                                      userProvider.id, widget.contact.first.id)
                                  .then((value) {
                                Navigator.pop(context);
                                Flushbar(
                                        backgroundColor:
                                            Theme.of(context).accentColor,
                                        animationDuration:
                                            const Duration(milliseconds: 200),
                                        message:
                                            '${widget.contact.first.username} is blocked')
                                    .show(context);
                              });
                            },
                            mainActionText: 'Block',
                            secondaryActionText: 'Let me think about it',
                            function1: () => Navigator.pop(context),
                          );
                        }),
                  ),
          ],
        );
      }
    }
  }

  Widget requestTile(User userProvider) {
    if (userProvider.id == widget.contact.first.id) {
      return Column(
        children: [
          Divider(
            endIndent: 20,
            indent: 20,
            thickness: 0.5,
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequestsPages(
                            userProvider: userProvider,
                            contact: userProvider,
                          )));
            },
            leading: Container(
              height: 40,
              width: 40,
              child: Stack(children: [
                Align(
                    alignment: Alignment.center,
                    child: LastRequest(
                      stream: _firebaseMethods.fetchReceivedRequests(
                          userId: userProvider.id),
                    )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: requestCount == 0
                      ? Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).accentColor,
                              )))
                      : Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          child: Text(
                            '$requestCount',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .apply(fontSizeFactor: 0.8),
                            textAlign: TextAlign.center,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).accentColor)),
                )
              ]),
            ),
            title: Text(
                requestCount == 0
                    ? 'Follow Requests'
                    : '$requestCount Follow Requests',
                style: Theme.of(context).textTheme.bodyText1),
            subtitle: Text('Accept or Refuse requests',
                style: Theme.of(context).textTheme.caption),
          ),
        ],
      );
    } else {
      return Container(
        height: 20,
        width: 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User userProvider = Provider.of<UserProvider>(context).getUser;
    return Consumer<AppTheme>(
        builder: (context, AppTheme appTheme, Widget child) {
      return AnswerLayout(
        scaffold: FutureBuilder(
            future: widget.contact.length == 1
                ? _authMethods.getUserWithId(widget.contact.first.id)
                : _authMethods.getUserWithId(widget.contact.first.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                    body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserCircle(
                      height: 50,
                      width: 50,
                      child: CachedImage(imageNotAvailable),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'User not Found',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ));
              }
              if (!snapshot.hasData) {
                return Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                    ),
                    body: Column(
                      children: [
                        ProfilePageShimmer(),
                      ],
                    ));
              }
              return Scaffold(
                appBar: PreferredSize(
                    child: Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      icon: Icon(Feather.arrow_left),
                                      onPressed: () => Navigator.pop(context)),
                                  SizedBox(width: 16),
                                  Text(
                                      isYouBlocked
                                          ? 'Loup-garou'
                                          : (widget.group &&
                                                  widget.chat != null)
                                              ? widget.chat.groupName
                                              : widget.contact.first.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                  SizedBox(width: 16),
                                  (isYouBlocked || isUserBlocked)
                                      ? Container()
                                      : OnlineIndic(
                                          uid: widget.contact.first.id,
                                          height: 10)
                                ],
                              ),
                              widget.group
                                  ? Container()
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                          _displayButton(
                                              userProvider, userProvider),
                                          userProvider.id ==
                                                  widget.contact.first.id
                                              ? IconButton(
                                                  icon: Icon(Feather.settings),
                                                  onPressed: () =>
                                                      settingsSheet())
                                              : Container(),
                                        ])
                            ])),
                    preferredSize: Size.fromHeight(kToolbarHeight * 1.5)),
                body: SingleChildScrollView(
                  child: widget.group
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              alignment: Alignment.centerLeft,
                              child: Text('Members',
                                  style: Theme.of(context).textTheme.bodyText1),
                            ),
                            for (var us = 0;
                                us < widget.chat.members.length;
                                us++)
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                onTap: () {
                                  List<User> groupMembers = [];
                                  groupMembers.add(widget.contact[us]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProfilePage(
                                                chat: widget.chat,
                                                group: false,
                                                userProvider: userProvider,
                                                contact: groupMembers,
                                              )));
                                },
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: CircleAvatar(
                                            radius: 24,
                                            backgroundImage: widget.contact[us]
                                                        .profileUrl !=
                                                    null
                                                ? CachedNetworkImageProvider(
                                                    widget
                                                        .contact[us].profileUrl)
                                                : CachedNetworkImageProvider(
                                                    imageNotAvailable)),
                                      ),
                                      Align(
                                          alignment: Alignment.bottomRight,
                                          child: widget.chat.members.values
                                                  .toList()[us]
                                                  .contains('admin')
                                              ? Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Theme.of(
                                                                  context)
                                                              .accentColor)),
                                                  child: Icon(Feather.user,
                                                      size: 14,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                )
                                              : null)
                                    ],
                                  ),
                                ),
                                title: Text(
                                  widget.contact[us].username,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .apply(fontSizeFactor: 1.3),
                                ),
                                subtitle: Text(
                                    widget.chat.members.values
                                        .toList()[us]
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .apply(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .color
                                                .withOpacity(0.7))),
                                trailing: IconButton(
                                    icon: Icon(
                                        (Platform.isIOS || Platform.isMacOS)
                                            ? Icons.more_horiz
                                            : Icons.more_vert,
                                        color: Theme.of(context)
                                            .primaryIconTheme
                                            .color),
                                    onPressed: () {
                                      //TODO menu
                                    }),
                              ),
                            if (widget.chat.members.length > 5)
                              TextButton(
                                child: Text('Show All',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                onPressed: () {},
                              ),
                            for (var us = 0;
                                us < widget.chat.members.length;
                                us++)
                              (widget.chat.members.values.toList()[us] ==
                                          'admin' &&
                                      widget.chat.members.keys.toList()[us] ==
                                          userProvider.id)
                                  ? ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20,
                                      ),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .accentColor)),
                                          child: Icon(Feather.plus,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                      title: Text(
                                        'Add member',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .apply(fontSizeFactor: 1.25),
                                      ),
                                    )
                                  : Container(height: 0),
                            Container(
                              margin: EdgeInsets.only(
                                  left: 20, top: 20, bottom: 20),
                              alignment: Alignment.centerLeft,
                              child: Text('Attachments',
                                  style: Theme.of(context).textTheme.bodyText1),
                            ),
                            sharedMedia(userProvider),
                            _displaySettingList(appTheme, userProvider)
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _displayFollowBack(userProvider),
                            _displayAcceptOrRefuseRequest(userProvider),
                            const SizedBox(height: 20),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: isYouBlocked
                                        ? const CircleAvatar(
                                            radius: 60,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    imageNotAvailable))
                                        : CircleAvatar(
                                            radius: 60,
                                            backgroundImage: widget.contact
                                                        .first.profileUrl !=
                                                    null
                                                ? CachedNetworkImageProvider(
                                                    widget.contact.first
                                                        .profileUrl)
                                                : const CachedNetworkImageProvider(
                                                    imageNotAvailable),
                                          ),
                                  ),
                                  (isUserBlocked || isYouBlocked)
                                      ? Container()
                                      : Align(
                                          alignment: Alignment.bottomLeft,
                                          widthFactor: 7.3,
                                          child: OnlineIndic(
                                              height: 20,
                                              uid: userProvider.id)),
                                  (isUserBlocked || isYouBlocked)
                                      ? Container()
                                      : Align(
                                          heightFactor: 1.5,
                                          widthFactor:
                                              messageOptionOpen ? 0.8 : 7.3,
                                          child: _displayMessageButton(
                                              userProvider, userProvider)),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            isYouBlocked
                                ? Container()
                                : widget.contact.first.name != null
                                    ? Text(widget.contact.first.name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6)
                                    : Container(),
                            SizedBox(height: 16),
                            isYouBlocked
                                ? Container()
                                : widget.contact.first.bio != null
                                    ? ShowMoreText(
                                        widget.contact.first.bio,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                        maxLength: 30,
                                        showMoreText: 'more.',
                                      )
                                    : Container(),
                            SizedBox(height: 16),
                            (isUserBlocked || isYouBlocked)
                                ? Container()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => FollowingPage(
                                                  userProvider: userProvider,
                                                  contact:
                                                      widget.contact.first)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Column(
                                            children: [
                                              Text(followingCount.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                              Text('Following',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        thickness: 2,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FollowersPage(
                                                userProvider: userProvider,
                                                contact: widget.contact.first),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Column(
                                            children: [
                                              Text(followerCount.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                              Text('Followers',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            isUserBlocked
                                ? TextButton.icon(
                                    icon: Icon(Feather.slash,
                                        color: Theme.of(context)
                                            .accentIconTheme
                                            .color),
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text('Unblock',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2),
                                    ),
                                    style: TextButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).accentColor),
                                    onPressed: () => showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return CustomDialog(
                                            title: 'Unblock',
                                            content: Text(
                                              'Are you sure ${widget.contact.first.username} will be able to find you after unblocking?',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                            function: () {
                                              _firebaseMethods
                                                  .unblockUser(userProvider.id,
                                                      widget.contact.first.id)
                                                  .then((value) {
                                                Navigator.pop(context);
                                                Flushbar(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .accentColor,
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        message:
                                                            '${widget.contact.first.username} is unblocked')
                                                    .show(context);
                                              });
                                            },
                                            mainActionText: 'Unblock',
                                            secondaryActionText:
                                                'Let me think about it',
                                            function1: () =>
                                                Navigator.pop(context),
                                          );
                                        }))
                                : sharedMedia(userProvider),
                            requestTile(userProvider),
                            _displaySettingList(appTheme, userProvider)
                          ],
                        ),
                ),
              );
            }),
      );
    });
  }
}

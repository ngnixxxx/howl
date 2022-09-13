import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/enum/view_state.dart';
import 'package:howl/models/chat.dart';
import 'package:howl/models/message.dart';
import 'package:howl/models/user.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; //for date locale

import 'package:howl/pages/answer_layout.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/providers/disappearing_image_provider.dart';
import 'package:howl/providers/sending_provider.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/utils/call_utils.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/utils/permissions.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:howl/widgets/cached_image.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:howl/widgets/online_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:social_media_widgets/snapchat_dismissible.dart';
import 'package:story_view/story_view.dart';
import 'disappearing_camera.dart';

class MessagesPage extends StatefulWidget {
  final List<User> receivers;
  final User userProvider;
  final bool group;
  final Chat chat;
  MessagesPage({
    this.receivers,
    this.group,
    this.userProvider,
    this.chat,
  });
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with TickerProviderStateMixin {
  TextEditingController _sendController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  UserProvider userProvider;

  FocusNode _sendFocus = FocusNode();
  Animation<double> animation;
  AnimationController controller, controller1;
  final StoryController storyController = StoryController();
  bool isTyping = false;
  bool isReceiverTyping = false;
  bool isMediaOpen;
  bool viewingImage = false;
  bool newMessage = false;
  bool isRequest = false;
  bool isUserBlocked = false;
  bool isYouBlocked = false;
  bool isRecording = false;
  bool isShouting = false;
  var listMessage;
  bool delete = false;
  String currentUserId;
  User sender;
  String username, profile;

  DisappearingImageProvider _uploadProvider;
  SendingProvider _sendingProvider;

  List<AssetEntity> _mediaList = [];

  @override
  void initState() {
    super.initState();
    if (!widget.group) {
      setupIsRequestReceived(widget.userProvider);
      setupIsBlocked(widget.userProvider);
      setupIsYouBlocked(widget.userProvider);
    }
    isMediaOpen = false;
    // controller = AnimationController(
    //      vsync: this, duration: Duration(milliseconds: 2000));

    controller.forward();
    controller.reverse();
  }

  setupIsRequestReceived(User userProvider) async {
    bool requestReceived = await _firebaseMethods.isRequestReceived(
      currentUserId: widget.userProvider.id,
      userId: widget.receivers.first.id,
    );
    setState(() {
      isRequest = requestReceived;
      print(isRequest.toString());
    });
  }

  setupIsBlocked(User userProvider) async {
    bool userBlocked = await _firebaseMethods.isUserBlocked(
      currentUserId: widget.userProvider.id,
      userId: widget.receivers.first.id,
    );
    setState(() {
      isUserBlocked = userBlocked;
    });
  }

  setupIsYouBlocked(User userProvider) async {
    bool youBlocked = await _firebaseMethods.isUserBlocked(
      currentUserId: widget.receivers.first.id,
      userId: widget.userProvider.id,
    );
    setState(() {
      isYouBlocked = youBlocked;
    });
  }

  @override
  void dispose() {
    _sendController?.dispose();
    controller?.dispose();
    controller1?.dispose();
    storyController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _uploadProvider = Provider.of<DisappearingImageProvider>(context);
    _sendingProvider = Provider.of<SendingProvider>(context);
    userProvider = Provider.of<UserProvider>(context);
    print(widget.receivers.first.id);
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
          child: Container(
            padding: EdgeInsets.only(right: 20, left: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        padding: const EdgeInsets.only(top: 20),
                        icon: Icon(
                          Feather.arrow_left,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                        onPressed: () => Navigator.pop(context)),
                    InkWell(
                      onTap: () {
                        List<User> profileMember = widget.receivers;

                        profileMember.remove(userProvider.getUser);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfilePage(
                                    contact: widget.group
                                        ? widget.receivers
                                        : profileMember,
                                    group: widget.group,
                                    chat: widget.chat,
                                    userProvider: userProvider.getUser)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              isYouBlocked
                                  ? 'Loup-garou'
                                  : widget.group
                                      ? widget.chat.groupName
                                      : widget.receivers
                                          .firstWhere((element) =>
                                              element.username !=
                                              userProvider.getUser.username)
                                          .username,
                              overflow: TextOverflow.clip,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            widget.group
                                ? Container()
                                : Text(
                                    isYouBlocked
                                        ? 'user not found'
                                        : widget.receivers
                                            .firstWhere((element) =>
                                                element.name !=
                                                userProvider.getUser.name)
                                            .name,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isYouBlocked
                            ? Container()
                            : IconButton(
                                icon: Icon(
                                  Feather.video,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                ),
                                onPressed: () async => await Permissions
                                        .cameraAndMicrophonePermissionsGranted()
                                    ? CallUtils.dial(
                                        from: userProvider.getUser,
                                        to: widget.receivers.firstWhere(
                                            (element) =>
                                                element !=
                                                userProvider.getUser),
                                        context: context)
                                    : showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return CustomDialog(
                                            title: 'Opps',
                                            content: Text(
                                                'You need to open settings and grant the app permission to the device camera and microphone',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1),
                                            mainActionText: 'Open Settings',
                                            function: () =>
                                                PhotoManager.openSetting(),
                                            secondaryActionText: 'Canel',
                                            function1: () {
                                              Navigator.pop(context);
                                            },
                                          );
                                        }),
                              ),
                        SizedBox(width: 10),
                        if (widget.group)
                          Container(
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 18,
                                child: Wrap(children: [
                                  for (var us = 0;
                                      us < widget.receivers.length;
                                      us++)
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundImage: widget.receivers[us]
                                              .profileUrl.isNotEmpty
                                          ? CachedNetworkImageProvider(profile =
                                              widget.receivers[us].profileUrl)
                                          : CachedNetworkImageProvider(
                                              imageNotAvailable[us]),
                                      backgroundColor: Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.15),
                                    )
                                ]),
                              ))
                        else
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: !widget.group && isYouBlocked
                                    ? CircleAvatar(
                                        radius: 18,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                imageNotAvailable))
                                    : CircleAvatar(
                                        radius: 18,
                                        backgroundImage: widget.receivers
                                                .firstWhere((element) =>
                                                    element.profileUrl !=
                                                    userProvider
                                                        .getUser.profileUrl)
                                                .profileUrl
                                                .isNotEmpty
                                            ? CachedNetworkImageProvider(
                                                profile = widget.receivers
                                                    .firstWhere((element) =>
                                                        element.profileUrl !=
                                                        userProvider
                                                            .getUser.profileUrl)
                                                    .profileUrl)
                                            : CachedNetworkImageProvider(
                                                imageNotAvailable),
                                        backgroundColor: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.15),
                                      ),
                              ),
                              (isYouBlocked || isUserBlocked)
                                  ? Container()
                                  : Positioned(
                                      right: 0,
                                      bottom: 30,
                                      child: OnlineIndic(
                                        height: 10,
                                        uid: widget.receivers
                                            .firstWhere((element) =>
                                                element.id !=
                                                userProvider.getUser.id)
                                            .id,
                                      ),
                                    ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: Stack(children: [
                Align(child: messageList(), alignment: Alignment.center),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: newMessage
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.2)),
                          child: Icon(
                            Feather.arrow_down,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                        )
                      : Container(),
                ),
              ]),
            ),
            if (_sendingProvider.getViewState == ViewState.LOADING)
              Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      sendingLayout(),
                      SizedBox(width: 6),
                      Icon(Feather.send, size: 10),
                    ],
                  ))
            else
              Container(height: 0, width: 0),
            if (_uploadProvider.getViewState == ViewState.LOADING)
              Container(
                  alignment: Alignment.centerRight,
                  child: disappearingLoading())
            else
              Container(),
            Container(
                alignment: Alignment.centerLeft,
                child: widget.chat == null
                    ? Container(width: 0, height: 0)
                    : receiverTyping()),
            isYouBlocked
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("You can't reach this user"),
                    height: 50,
                    decoration:
                        BoxDecoration(color: Theme.of(context).accentColor))
                : isUserBlocked
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("You have blocked this user",
                                style: Theme.of(context).textTheme.bodyText2,
                                softWrap: true),
                            SizedBox(width: 16),
                            SizedBox(
                              width: 85,
                              height: 30,
                              child: OutlinedButton(
                                  onPressed: () => showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return CustomDialog(
                                          title: 'Unblock',
                                          content: Text(
                                            'Are you sure ${widget.receivers.first.username} will be able to find you after unblocking?',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                          function: () {
                                            _firebaseMethods.unblockUser(
                                                widget.userProvider.id,
                                                widget.receivers.first.id);
                                            setState(() {});
                                            Navigator.pop(context);
                                            //TODO snkckbar
                                          },
                                          mainActionText: 'Unblock',
                                          secondaryActionText:
                                              'Let me think about it',
                                          function1: () =>
                                              Navigator.pop(context),
                                        );
                                      }),
                                  child: Text('Unblock',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .apply(fontSizeFactor: 0.7)),
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .color))),
                            )
                          ],
                        ),
                        height: 50,
                        decoration:
                            BoxDecoration(color: Theme.of(context).accentColor))
                    : messageBox(),
          ],
        ),
      ),
    );
  }

  Widget disappearingLoading() {
    Radius messageRadius = Radius.circular(25);

    return Container(
      margin: EdgeInsets.only(right: 20, bottom: 20),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Feather.play_circle,
                color: Theme.of(context).accentIconTheme.color.withOpacity(0.5),
                size: 18),
            SizedBox(width: 5),
            Text(
              'Photo',
              style: Theme.of(context).textTheme.bodyText2.apply(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .color
                      .withOpacity(0.5)),
            )
          ],
        ),
      ),
    );
  }

  Widget disappearingPhoto(Message message) {
    if (message.viewModes == 'Keep') {
      return Container(
          height: 160,
          width: 90,
          padding: EdgeInsets.all(4),
          child: CachedImage(message.photoUrl,
              radius: 16, fit: BoxFit.cover, isRound: false),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Theme.of(context).accentColor.withOpacity(0.7),
                  width: 0.7)));
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(message.viewModes == 'Once' ? Feather.zap : Feather.play_circle,
              color: Theme.of(context).accentIconTheme.color, size: 20),
          SizedBox(width: 5),
          Text('Photo', style: Theme.of(context).textTheme.bodyText2),
        ],
      );
    }
  }

  Widget disappearingVideo(Message message) {
    return message.viewModes == 'Keep'
        ? Container(
            height: 160,
            width: 90,
            padding: EdgeInsets.all(2),
            child: CachedImage(
              message.photoUrl,
              fit: BoxFit.cover,
              radius: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: message.seen
                  ? Border.all(
                      color: Theme.of(context).accentColor.withOpacity(0.7),
                      width: 0.7,
                    )
                  : Border.all(color: Theme.of(context).accentColor, width: 1),
            ))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  message.viewModes == 'Once'
                      ? Feather.zap
                      : Feather.play_circle,
                  color: Theme.of(context).accentIconTheme.color,
                  size: 20),
              SizedBox(width: 5),
              Text('Video', style: Theme.of(context).textTheme.bodyText2),
            ],
          );
  }

  Widget disappearingRecieverPhoto(Message message) {
    if (message.viewModes == 'Keep') {
      return Container(
          height: 160,
          width: 90,
          padding: EdgeInsets.all(2),
          child: CachedImage(message.photoUrl,
              fit: BoxFit.cover, radius: 16, isRound: false),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: message.seen
                  ? Border.all(
                      color: Theme.of(context).accentColor.withOpacity(0.3))
                  : Border.all(
                      color: Theme.of(context).accentColor,
                      width: message.seen ? 0.5 : 1),
              color: Colors.transparent));
    } else {
      return message.viewModes == 'Once' ||
              message.viewModes == 'View' && message.viewTimes != '0'
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(message.viewModes == 'Once' ? Feather.zap : Feather.play,
                  color: Theme.of(context).accentIconTheme.color, size: 20),
              SizedBox(width: 5),
              Text(viewingImage ? 'Opening..' : 'View Photo',
                  style: Theme.of(context).textTheme.bodyText2)
            ])
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(message.viewModes == 'Once' ? Feather.zap : Feather.play,
                    color: Theme.of(context)
                        .accentIconTheme
                        .color
                        .withOpacity(0.5),
                    size: 20),
                SizedBox(width: 5),
                Text('Photo',
                    style: Theme.of(context).textTheme.bodyText2.apply(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.5))),
              ],
            );
    }
  }

  Widget receiverTyping() {
    List<String> receiverList = [];

    for (var receiver = 0; receiver < widget.receivers.length; receiver++) {
      receiverList.add(widget.receivers[receiver].id);
    }
    if (!receiverList.contains(userProvider.getUser.id)) {
      receiverList.add(userProvider.getUser.id);
    }
    Radius messageRadius = Radius.circular(25);
    return StreamBuilder(
        stream: _firebaseMethods.fetchChat(
          userId: userProvider.getUser.id,
          chatId: receiverList,
        ),
        builder: (context, snapshot) {
          Chat chat = Chat.fromMap(snapshot.data.data);
          if (!snapshot.hasData) {
            return Container(width: 0, height: 0);
          }
          if (!snapshot.hasError) {
            return Container(width: 0, height: 0);
          }
          if (widget.chat.receiversTyping.containsValue(true))
            return Opacity(
              opacity: 0.7,
              child: Padding(
                padding: EdgeInsets.only(left: 20, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var us = 0;
                        us < widget.chat.receiversTyping.length;
                        us++)
                      if (widget.chat.receiversTyping.values.toList()[us] ==
                          true)
                        CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                widget.receivers[us].profileUrl != null
                                    ? CachedNetworkImageProvider(
                                        widget.receivers[us].profileUrl)
                                    : CachedNetworkImageProvider(
                                        imageNotAvailable[us])),
                    Container(
                      margin: EdgeInsets.only(left: 6, bottom: 6),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.3, color: Theme.of(context).accentColor),
                        borderRadius: BorderRadius.only(
                          topLeft: messageRadius,
                          topRight: messageRadius,
                          bottomRight: messageRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        child: Icon(
                          Entypo.dots_three_horizontal,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          return Container(height: 0, width: 0);
        });
  }

  Widget messageList() {
    List<String> receiverList = [];
    for (var us = 0; us < widget.receivers.length; us++) {
      receiverList.add(widget.receivers[us].id);
    }
    receiverList.sort();
    String groupId = receiverList.toString();
    print('GROUPPPP IDD $groupId');
    return StreamBuilder(
        stream: messagesRef
            .doc(userProvider.getUser.id)
            .collection(groupId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Scaffold(
              body: Center(
                child: Text('No messages yet',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            );
          } else if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.none) {
            return Scaffold(body: CircularProgressIndicator());
          }
          // SchedulerBinding.instance.addPostFrameCallback((_) {
          //   _scrollController.animateTo(
          //     _scrollController.position.minScrollExtent,
          //     duration: Duration(milliseconds: 250),
          //     curve: Curves.easeInOut,
          //   );
          // });
          return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: snapshot.data.docs.length,
              reverse: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                listMessage = snapshot.data.docs;
                return messageListItem(index, snapshot.data.docs[index]);
              });
        });
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['senderId'] != userProvider.getUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['senderId'] == userProvider.getUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isNextMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['senderId'] != userProvider.getUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget messageListItem(int index, DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());
    return Container(
      margin: EdgeInsets.only(top: 3),
      child: Container(
        alignment: _message.senderId == userProvider.getUser.id
            ? Alignment.centerRight
            : _message.type == 'groupUpdate'
                ? Alignment.center
                : Alignment.centerLeft,
        child: _message.senderId == userProvider.getUser.id
            ? GestureDetector(
                onTap: () {
                  if (_message.viewModes == 'Keep') {
                    setState(() {
                      viewingImage = true;
                    });

                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (_, __, ___) => SnapchatDismiss(
                                  dismissHeight: 200,
                                  child: DisappearingView(
                                    message: _message,
                                    sendMessage: sendMessage,
                                    // userId: widget.receiver.id,
                                    currentUserId: userProvider.getUser.id,
                                    username: username,
                                    sendController: _sendController,
                                  ),
                                )));
                    setState(() {
                      viewingImage = false;
                    });
                  }
                },
                child: CupertinoContextMenu(
                    previewBuilder: (context, animation, widget) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.bottomLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              senderLayout(_message, index),
                              SizedBox(height: 10),
                              reactionSelectionWidget(_message, index),
                            ],
                          ),
                        ),
                    actions: [
                      CupertinoContextMenuAction(
                        trailingIcon: Feather.copy,
                        onPressed: () {},
                        child: Text('Copy',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                      ),
                      CupertinoContextMenuAction(
                        trailingIcon: Feather.arrow_right,
                        onPressed: () {},
                        child: Text('Forward',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                      ),
                      CupertinoContextMenuAction(
                        trailingIcon: Feather.message_circle,
                        onPressed: () {},
                        child: Text('Reply',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                      ),
                      CupertinoContextMenuAction(
                        isDestructiveAction: true,
                        trailingIcon: Feather.trash,
                        child: Text(
                            _message.senderId == userProvider.getUser.id
                                ? 'Unsend'
                                : 'Delete',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                        onPressed: _message.senderId == userProvider.getUser.id
                            ? () {
                                //TODO
                                // _firebaseMethods.unsendMessage(
                                //     widget.receiver.id,
                                //     userProvider.getUser.id,
                                //     snapshot);
                                setState(() {});
                                Navigator.pop(context);
                                print('Unsent');
                              }
                            : () {
                                Navigator.pop(context);
                                return showDialog(
                                    context: context,
                                    builder: (_) {
                                      return CustomDialog(
                                        title: 'Delete message',
                                        content: Text(
                                            "Deleted messages can't be recovered",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1),
                                        mainActionText: 'Delete',
                                        secondaryActionText: 'Cancel',
                                        function: () {
                                          //TODO
                                          // _firebaseMethods.deleteMessage(
                                          //     widget.receiver.id,
                                          //     userProvider.getUser.id,
                                          //     snapshot);
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        function1: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              },
                      ),
                    ],
                    child: _message.type == 'groupUpdate'
                        ? updateLayout(index, _message)
                        : senderLayout(_message, index)))
            : GestureDetector(
                onTap: viewingImage
                    ? () {}
                    : () {
                        if (_message.type == 'disappearingImage') {
                          setState(() {
                            viewingImage = true;
                          });

                          if (_message.viewModes == 'Once' ||
                              _message.viewModes == 'View' &&
                                  _message.viewTimes != '0') {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) =>
                                        SnapchatDismiss(
                                          dismissHeight: 200,
                                          child: DisappearingView(
                                            message: _message,
                                            sendMessage: sendMessage,
                                            // userId: widget.receiver.id,
                                            currentUserId:
                                                userProvider.getUser.id,
                                            username: username,
                                            sendController: _sendController,
                                          ),
                                        )));
                            setState(() {
                              viewingImage = false;
                            });
                          } else if (_message.viewModes == 'Keep') {
                            setState(() {
                              viewingImage = true;
                            });
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) =>
                                        SnapchatDismiss(
                                          dismissHeight: 200,
                                          child: DisappearingView(
                                            message: _message,
                                            sendMessage: sendMessage,
                                            // userId: widget.receiver.id,
                                            currentUserId:
                                                userProvider.getUser.id,
                                            username: username,
                                            sendController: _sendController,
                                          ),
                                        )));
                            setState(() {
                              viewingImage = false;
                            });
                          }
                        }
                      },
                child: CupertinoContextMenu(
                    previewBuilder: (context, animation, widget) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.bottomLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              receiverLayout(index, _message),
                              SizedBox(height: 10),
                              reactionSelectionWidget(_message, index),
                            ],
                          ),
                        ),
                    actions: [
                      CupertinoContextMenuAction(
                        trailingIcon: Feather.copy,
                        onPressed: () {},
                        child: Text('Copy',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                      ),
                      CupertinoContextMenuAction(
                        trailingIcon: Feather.arrow_right,
                        onPressed: () {},
                        child: Text('Forward',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                      ),
                      CupertinoContextMenuAction(
                        trailingIcon: Feather.message_circle,
                        onPressed: () {},
                        child: Text('Reply',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                      ),
                      CupertinoContextMenuAction(
                        isDestructiveAction: true,
                        trailingIcon: Feather.trash,
                        child: Text(
                            _message.senderId == userProvider.getUser.id
                                ? 'Unsend'
                                : 'Delete',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: text)),
                        onPressed: _message.senderId == userProvider.getUser.id
                            ? () {
                                //TODO
                                // _firebaseMethods.unsendMessage(
                                //     widget.receiver.id,
                                //     userProvider.getUser.id,
                                //     snapshot);
                                setState(() {});
                                Navigator.pop(context);
                                print('Unsent');
                              }
                            : () {
                                Navigator.pop(context);
                                return showDialog(
                                    context: context,
                                    builder: (_) {
                                      return CustomDialog(
                                        title: 'Delete message',
                                        content: Text(
                                            "Deleted messages can't be recovered",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1),
                                        mainActionText: 'Delete',
                                        secondaryActionText: 'Cancel',
                                        function: () {
                                          //TODO
                                          // _firebaseMethods.deleteMessage(
                                          //     widget.receiver.id,
                                          //     userProvider.getUser.id,
                                          //     snapshot);
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        function1: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              },
                      ),
                    ],
                    child: _message.type == 'groupUpdate'
                        ? updateLayout(index, _message)
                        : receiverLayout(index, _message))),
      ),
    );
  }

  Widget updateLayout(int index, Message message) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          Text(
            message.senderId == userProvider.getUser.id
                ? 'You ${message.message}'
                : '${widget.receivers.singleWhere((element) => element.id == message.senderId).username} ${message.message}',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfilePage(
                          chat: widget.chat,
                          group: widget.group,
                          contact: widget.receivers,
                          userProvider: userProvider.getUser,
                        ))),
            child: Text('Update Conversation Settings',
                style: Theme.of(context).textTheme.bodyText1.apply(
                    color: Theme.of(context).accentColor, fontSizeFactor: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget reactionWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Icon(Feather.heart, size: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget reactionSelectionWidget(Message message, int index) {
    List<String> emojis = ['❤', '😂', '😭', '😮', '👍', '👎'];
    return Container(
      height: 50,
      width: 250,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColor),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        for (var emoji in emojis)
          GestureDetector(
            child: Text(emoji, style: Theme.of(context).textTheme.headline6),
            onTap: () {},
          ),
      ]),
    );
  }

  messageLongPress(Message message, DocumentSnapshot snapshot) {
    var type = message.type;
    if (type == 'text') {
      return CupertinoPopupSurface(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Feather.copy), onPressed: () {}),
                SizedBox(height: 5),
                Text('Copy', style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Feather.arrow_right), onPressed: () {}),
                SizedBox(height: 5),
                Text('Forward', style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: Icon(Feather.trash),
                    onPressed: message.senderId == userProvider.getUser.id
                        ? () {
                            //TODO
                            // _firebaseMethods.unsendMessage(
                            //     widget.receiver.id,
                            //     userProvider.getUser.id,
                            //     snapshot);
                            setState(() {});
                            Navigator.pop(context);
                            print('Unsent');
                          }
                        : () {
                            Navigator.pop(context);
                            return showDialog(
                                context: context,
                                builder: (_) {
                                  return CustomDialog(
                                    title: 'Delete message',
                                    content: Text(
                                        "Deleted messages can't be recovered",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                    mainActionText: 'Delete',
                                    secondaryActionText: 'Cancel',
                                    function: () {
                                      //TODO
                                      // _firebaseMethods.deleteMessage(
                                      //     widget.receiver.id,
                                      //     userProvider.getUser.id,
                                      //     snapshot);
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    function1: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                });
                          }),
                SizedBox(height: 5),
                Text(
                    message.senderId == userProvider.getUser.id
                        ? 'Unsend'
                        : 'Delete',
                    style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Feather.alert_circle), onPressed: () {}),
                SizedBox(height: 5),
                Text('Report', style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
          ],
        ),
      ));
    } else {
      return showModalBottomSheet(
          context: context,
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Feather.arrow_right), onPressed: () {}),
                      SizedBox(height: 5),
                      Text('Forward',
                          style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Feather.trash),
                          onPressed: message.senderId == userProvider.getUser.id
                              ? () {
                                  //TODO
                                  // _firebaseMethods.unsendMessage(
                                  //     widget.receiver.id,
                                  //     userProvider.getUser.id,
                                  //     snapshot);
                                  setState(() {});
                                  Navigator.pop(context);
                                  print('Unsent');
                                }
                              : () {
                                  Navigator.pop(context);
                                  return showDialog(
                                      context: context,
                                      builder: (_) {
                                        return CustomDialog(
                                          title: 'Delete message',
                                          content: Text(
                                              "Deleted messages can't be recovered",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                          mainActionText: 'Delete',
                                          secondaryActionText: 'Cancel',
                                          function: () {
                                            //TODO
                                            // _firebaseMethods.deleteMessage(
                                            //     widget.receiver.id,
                                            //     userProvider.getUser.id,
                                            //     snapshot);
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                          function1: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      });
                                }),
                      SizedBox(height: 5),
                      Text(
                          message.senderId == userProvider.getUser.id
                              ? 'Unsend'
                              : 'Delete',
                          style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Feather.alert_circle), onPressed: () {}),
                      SizedBox(height: 5),
                      Text('Report',
                          style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                ],
              ),
            );
          });
    }
  }

  Widget sendingLayout() {
    Radius messageRadius = Radius.circular(25);
    initializeDateFormatting();

    var time = DateFormat.Hm().format(DateTime.now().toLocal());

    return Container(
        margin: EdgeInsets.only(top: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Text(_sendController.text.toString(),
                    style: Theme.of(context).textTheme.bodyText2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    time.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(fontSizeFactor: 0.65),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget senderLayout(Message message, int index) {
    Radius messageRadius = Radius.circular(25);

    var type = message.type;
    var seen = message.seen;
    initializeDateFormatting();

    var time = DateFormat.Hm().format(message.timestamp.toDate().toLocal());

    return Container(
        margin: isNextMessageRight(index)
            ? EdgeInsets.only(top: 0)
            : EdgeInsets.only(top: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: type == 'disappearingImage' && message.viewModes == 'Keep'
              ? Colors.transparent
              : Theme.of(context).accentColor,
          borderRadius: type == 'disappearingImage'
              ? BorderRadius.all(messageRadius)
              : isLastMessageLeft(index)
                  ? BorderRadius.only(
                      topLeft: messageRadius,
                      topRight: messageRadius,
                      bottomLeft: messageRadius,
                      bottomRight: Radius.circular(4),
                    )
                  : BorderRadius.all(messageRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Padding(
                    padding: message.viewModes == 'Keep'
                        ? EdgeInsets.zero
                        : type == 'text'
                            ? EdgeInsets.fromLTRB(16, 10, 8, 14)
                            : EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                    child: getMessage(message))),
            if (type == 'disappearingImage')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      time.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .apply(fontSizeFactor: 0.65),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 6, right: 8, left: 4),
                    child: seen
                        ? Icon(Feather.check,
                            size: 16,
                            color: Theme.of(context).accentIconTheme.color)
                        : Container(),
                  ),
                ],
              )
          ],
        ));
  }

  Widget newMessageRecieved() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Divider(),
            ),
            Text('New Message', style: Theme.of(context).textTheme.caption),
            Flexible(
              child: Divider(),
            )
          ]),
    );
  }

  getMessage(Message message) {
    if (message.type == "disappearingImage") {
      return message.senderId == userProvider.getUser.id
          ? disappearingPhoto(message)
          : disappearingRecieverPhoto(message);
    } else if (message.type == 'image') {
      return message.photoUrl != null
          ? CachedImage(message.photoUrl, isRound: false)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  Icon(Feather.image,
                      color: Theme.of(context).accentIconTheme.color),
                  SizedBox(height: 10),
                  Text('Photo unavailable',
                      style: Theme.of(context).textTheme.bodyText1)
                ]);
    } else if (message.type == 'video') {
      return message.photoUrl != null
          ? CachedImage(
              message.photoUrl,
              height: 250,
              width: 300,
              radius: 10,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  Icon(Feather.video,
                      color: Theme.of(context).accentIconTheme.color),
                  SizedBox(height: 10),
                  Text('Video unavailable',
                      style: Theme.of(context).textTheme.bodyText1)
                ]);
    } else {
      return Text(
        message.message,
        style: message.senderId == userProvider.getUser.id
            ? Theme.of(context).textTheme.bodyText2
            : Theme.of(context).textTheme.bodyText1,
      );
    }
  }

  Widget receiverLayout(int index, Message message) {
    Radius messageRadius = Radius.circular(25);

    var type = message.type;
    var seen = message.seen;
    initializeDateFormatting();

    var time = DateFormat.Hm().format(message.timestamp.toDate().toLocal());

    return Column(
      children: [
        if (!seen)
          Align(alignment: Alignment.centerRight, child: newMessageRecieved())
        else
          Container(),
        if (widget.group)
          Container(
            margin: EdgeInsets.only(left: 50, bottom: 4),
            alignment: Alignment.centerLeft,
            child: Text(
                widget.receivers
                    .firstWhere((element) => element.id == message.senderId)
                    .username,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .apply(fontSizeFactor: 0.8)),
          )
        else
          Container(),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLastMessageRight(index))
                CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.receivers
                                .firstWhere(
                                    (element) => element.id == message.senderId)
                                .profileUrl !=
                            null
                        ? CachedNetworkImageProvider(widget.receivers
                            .firstWhere(
                                (element) => element.id == message.senderId)
                            .profileUrl)
                        : CachedNetworkImageProvider(imageNotAvailable))
              else
                Container(),
              SizedBox(width: isLastMessageRight(index) ? 8 : 38),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                decoration: BoxDecoration(
                  color:
                      type == 'disappearingImage' && message.viewModes != 'Keep'
                          ? pelorous
                          : Theme.of(context).primaryColor,
                  border: type == 'disappearingImage'
                      ? null
                      : Border.all(
                          width: 0.3, color: Theme.of(context).accentColor),
                  borderRadius: type == 'disappearingImage'
                      ? BorderRadius.all(messageRadius)
                      : isLastMessageRight(index)
                          ? BorderRadius.only(
                              topLeft: messageRadius,
                              topRight: messageRadius,
                              bottomRight: messageRadius,
                              bottomLeft: Radius.circular(4),
                            )
                          : BorderRadius.all(messageRadius),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: message.viewModes == 'Keep'
                              ? EdgeInsets.zero
                              : type == 'text'
                                  ? EdgeInsets.fromLTRB(16, 10, 8, 14)
                                  : EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                          child: getMessage(message)),
                      if (type == 'disappearingImage')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                time.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .apply(fontSizeFactor: 0.65),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 6, right: 12, left: 4),
                              child: seen
                                  ? Icon(Feather.check,
                                      size: 16,
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color)
                                  : Container(),
                            ),
                          ],
                        )
                    ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  setTypingTo(bool val) {
    _firebaseMethods.setToTyping(
        userProvider.getUser.id, widget.receivers.first.id, val);
    setState(() {
      isTyping = val;
    });
  }

  sendMessage() {
    var text = _sendController.text;
    var receiverMap = {
      userProvider.getUser.id: 'member',
    };

    for (var us = 0; us < widget.receivers.length; us++) {
      receiverMap[widget.receivers[us].id] = 'member';
    }
    Message _message = Message(
      senderId: userProvider.getUser.id,
      receiversId: receiverMap,
      message: text,
      seen: false,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    setState(() {
      isTyping = false;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _sendController.clear());
    });
    _firebaseMethods.addMessageToDb(
        _message, receiverMap.keys.toList(), userProvider.getUser.id);
  }

  _fetchNewMedia() async {
    var result = await Permission.accessMediaLocation.request();
    if (result.isGranted) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 20);
      setState(() {
        _mediaList = media;
      });
      print(media);
      print(albums);
    } else if (result.isDenied || result.isLimited) {
      Map<Permission, PermissionStatus> statues = await [
        Permission.storage,
        Permission.mediaLibrary,
      ].request();
    } else if (result.isPermanentlyDenied) {
      return showDialog(
          context: context,
          builder: (context) {
            return CustomDialog(
              title: 'Opps',
              content: Text(
                  'You need to open settings and grant the app permission to the device media library',
                  style: Theme.of(context).textTheme.bodyText1),
              mainActionText: 'Open Settings',
              function: () => PhotoManager.openSetting(),
              secondaryActionText: 'Canel',
              function1: () {
                setState(() {
                  isMediaOpen = false;
                });
                Navigator.pop(context);
              },
            );
          });
    }
  }

  Widget imageTab() {
    bool selected = false;
    _fetchNewMedia();
    return Column(
      children: [
        TextButton.icon(
            onPressed: () {},
            label:
                Text('Gallery', style: Theme.of(context).textTheme.bodyText1),
            icon: Icon(Icons.expand_more,
                color: Theme.of(context).primaryIconTheme.color)),
        Expanded(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemCount: _mediaList.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                    future: _mediaList[index].thumbDataWithSize(60, 60),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: 60,
                          width: 60,
                          margin: selected
                              ? const EdgeInsets.all(2)
                              : EdgeInsets.zero,
                          color: Theme.of(context).accentColor.withOpacity(0.2),
                          child: Image.memory(snapshot.data),
                        );
                      }
                      return Container(
                        height: 60,
                        width: 60,
                        margin: selected
                            ? const EdgeInsets.all(2)
                            : EdgeInsets.zero,
                      );
                    });
              }),
        ),
      ],
    );
  }

  fetchLocation() async {
    var result = await Permission.accessMediaLocation.status;
    if (result.isGranted) {
    } else if (result.isRestricted || result.isLimited) {
      return await Permission.location.request();
    } else if (result.isPermanentlyDenied) {
      return showDialog(
          context: context,
          builder: (context) {
            return CustomDialog(
              title: 'Opps',
              content: Text(
                  'You need to open settings and grant the app permission to the device location',
                  style: Theme.of(context).textTheme.bodyText1),
              mainActionText: 'Open Settings',
              function: () => PhotoManager.openSetting(),
              secondaryActionText: 'Canel',
              function1: () {
                setState(() {
                  isMediaOpen = false;
                });
                Navigator.pop(context);
              },
            );
          });
    }
  }

  Widget locationTab() {
    fetchLocation();

    return Container(
      child: Text('loacation'),
    );
  }

  Widget musicTab() {
    return Container(
      child: Text('music'),
    );
  }

  Widget documentTab() {
    return Container(
      child: Text('docs'),
    );
  }

  Widget mediaBox() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        color: Theme.of(context).accentColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Feather.image,
                color: Theme.of(context).accentIconTheme.color,
              )),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Feather.map_pin,
              color: Theme.of(context).accentIconTheme.color,
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Feather.music,
                color: Theme.of(context).accentIconTheme.color,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Feather.file,
                color: Theme.of(context).accentIconTheme.color,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Feather.user,
                color: Theme.of(context).accentIconTheme.color,
              )),
        ],
      ),
    );
  }

  double dragePosition = 0;
  double dragPercentage = 0;
  double height = 180;

  _updateDragPosition(Offset val) {
    double newDragPosition = 0;
    if (val.dx <= 0) {
      newDragPosition = 0;
    } else if (val.dx >= height) {
      newDragPosition = height;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      dragePosition = newDragPosition;
      dragPercentage = dragePosition / height;
    });
  }

  Widget messageBox() {
    return Column(
      children: [
        isMediaOpen ? mediaBox() : Container(),
        Stack(clipBehavior: Clip.none, children: [
          isShouting
              ? Positioned(
                  right: 30,
                  bottom: 20,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                      height: 200,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).accentColor),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        color: Theme.of(context).accentIconTheme.color,
                        width: 0.5,
                        height: height,
                      ),
                    ),
                    Icon(
                      Feather.send,
                      color: Theme.of(context).accentIconTheme.color,
                    ),
                  ]),
                )
              : Container(),
          isRecording
              ? Align(
                  alignment: Alignment.center,
                  heightFactor: 0.01,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).accentColor),
                    child: Icon(
                      Feather.mic,
                      size: 40,
                      color: Theme.of(context).accentIconTheme.color,
                    ),
                  ),
                )
              : Container(),
          Container(
            height: 50,
            margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: isMediaOpen
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))
                  : BorderRadius.circular(25),
              color: Theme.of(context).accentColor.withOpacity(0.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isRecording
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Feather.trash_2,
                          color: delete
                              ? Colors.red
                              : Theme.of(context).primaryIconTheme.color,
                        ),
                      )
                    : IconButton(
                        icon: isMediaOpen
                            ? RotationTransition(
                                turns: controller,
                                child: Transform.rotate(
                                  angle: pi / 4,
                                  child: Icon(
                                    Feather.plus_circle,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                  ),
                                ),
                              )
                            : RotationTransition(
                                turns: controller,
                                child: Icon(
                                  Feather.plus_circle,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                ),
                              ),
                        onPressed: () {
                          setState(() {
                            isMediaOpen = !isMediaOpen;
                          });
                        },
                      ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: isRecording
                        ? Text('Time',
                            style: Theme.of(context).textTheme.bodyText1)
                        : TextFormField(
                            enabled: true,
                            autocorrect: false,
                            enableInteractiveSelection: true,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1,
                            maxLines: 3,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            toolbarOptions: ToolbarOptions(
                                copy: true,
                                cut: true,
                                paste: true,
                                selectAll: true),
                            decoration: InputDecoration(
                                filled: false,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none),
                                disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                hintText: 'Message..'),
                            controller: _sendController,
                            focusNode: _sendFocus,
                            onChanged: (val) {
                              (val.length > 0 && val.trim() != "")
                                  ? setTypingTo(true)
                                  : setTypingTo(false);
                            },
                            autofocus: false,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                  ),
                ),
                GestureDetector(
                  onLongPress: isTyping
                      ? () {
                          setState(() {
                            isShouting = true;
                          });
                        }
                      : () {
                          setState(() {
                            isRecording = true;
                          });
                        },
                  onVerticalDragStart: (DragStartDetails start) {
                    if (isShouting) {
                      RenderBox box = context.findRenderObject();
                      Offset offset = box.globalToLocal(start.globalPosition);
                      _updateDragPosition(offset);
                    }
                  },
                  onVerticalDragUpdate: (DragUpdateDetails update) {
                    if (isShouting) {
                      RenderBox box = context.findRenderObject();
                      Offset offset = box.globalToLocal(update.globalPosition);
                      _updateDragPosition(offset);
                    }
                  },
                  onVerticalDragEnd: (DragEndDetails end) {
                    setState(() {});
                  },
                  onHorizontalDragStart: (DragStartDetails start) {
                    if (isRecording) {
                      RenderBox box = context.findRenderObject();
                      Offset offset = box.globalToLocal(start.globalPosition);
                      _updateDragPosition(offset);
                    }
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails update) {
                    if (isRecording) {
                      RenderBox box = context.findRenderObject();
                      Offset offset = box.globalToLocal(update.globalPosition);
                      _updateDragPosition(offset);
                    }
                  },
                  onHorizontalDragEnd: (DragEndDetails end) {
                    setState(() {});
                  },
                  onLongPressEnd: (LongPressEndDetails longPressEndDetails) {
                    if (!isTyping)
                      setState(() {
                        isRecording = false;
                      });
                    else
                      setState(() {
                        isShouting = false;
                      });
                  },
                  child: IconButton(
                      icon: isTyping
                          ? Icon(
                              Platform.isIOS && Platform.isMacOS
                                  ? Feather.arrow_up_circle
                                  : Feather.send,
                              color: Theme.of(context).primaryIconTheme.color,
                            )
                          : !isRecording
                              ? Icon(
                                  Feather.mic,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                )
                              : Container(),
                      onPressed: isTyping
                          ? () {
                              sendMessage();
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Press and hold to record a voice message')),
                              );
                            }),
                ),
                !isTyping
                    ? IconButton(
                        icon: Icon(
                          isRecording ? Feather.lock : Feather.camera,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DisappearingCameraPage(
                                      username: username,
                                      // userId: widget.receivers.id,
                                      currentUserId: userProvider.getUser.id,
                                      groupOrNormal: 'individual',
                                    ))))
                    : Container(),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}

class DisappearingView extends StatefulWidget {
  final Message message;
  final Function sendMessage;
  final String username, userId, currentUserId;
  final TextEditingController sendController;
  DisappearingView(
      {this.message,
      this.sendMessage,
      this.username,
      this.userId,
      this.currentUserId,
      this.sendController});
  @override
  _DisappearingViewState createState() => _DisappearingViewState();
}

class _DisappearingViewState extends State<DisappearingView> {
  StoryController storyController = StoryController();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  FocusNode disappearingNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    storyController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: StoryView(
              onStoryShow: (show) async {
                await _firebaseMethods.updateDisappearingViewTimes(
                    widget.message, widget.userId, widget.currentUserId);
              },
              repeat: true,
              storyItems: [
                StoryItem.pageImage(
                  url: widget.message.photoUrl != null
                      ? widget.message.photoUrl
                      : null,
                  controller: storyController,
                ),
              ],
              controller: storyController,
            ),
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
                // gradient: LinearGradient(
                //     List: [Colors.black, Colors.black.withOpacity(0.4)]),
                ),
            child: Padding(
              padding: EdgeInsets.only(top: 60, left: 20, bottom: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).accentColor.withOpacity(0.2),
                  ),
                  SizedBox(width: 16),
                  Text(widget.username,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .apply(color: Colors.white)),
                  SizedBox(width: 10),
                  OnlineIndic(height: 5, uid: widget.userId),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                        timeago.format(widget.message.timestamp.toDate(),
                            locale: 'en_short'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .apply(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 8, left: 20, right: 20),
                padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white.withAlpha(180),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Feather.camera,
                          color: text,
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DisappearingCameraPage(
                                    username: widget.username,
                                    userId: widget.userId,
                                    currentUserId: widget.currentUserId)))),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 10,
                        ),
                        child: TextFormField(
                          enabled: true,
                          autocorrect: false,
                          enableInteractiveSelection: true,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .apply(color: Colors.black),
                          maxLines: 3,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          toolbarOptions: ToolbarOptions(
                              copy: true,
                              cut: true,
                              paste: true,
                              selectAll: true),
                          decoration: InputDecoration(
                              filled: false,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              hintText: 'Reply to ${widget.username}..',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .apply(color: Colors.black.withOpacity(0.4))),
                          controller: widget.sendController,
                          focusNode: disappearingNode,
                          autofocus: false,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ),
                    widget.sendController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Feather.send,
                              color: text,
                            ),
                            onPressed: () => widget.sendMessage)
                        : Container(height: 0, width: 0),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

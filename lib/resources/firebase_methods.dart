import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:howl/models/message.dart';
import 'package:howl/models/request.dart';
import 'package:howl/models/user.dart';
import 'package:howl/providers/sending_provider.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/models/follower.dart';
import 'package:howl/models/chat.dart';

class FirebaseMethods {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User user;
  SendingProvider _sendingProvider;

  Future addPhoneDataToDb(auth.User currentUser, String username) async {
    user = User(
      id: currentUser.uid,
      email: '',
      name: currentUser.displayName,
      profileUrl: currentUser.photoURL,
      username: username,
      private: false,
      bio: '',
      birthdate: '',
      phone: currentUser.phoneNumber,
      gender: '',
      online: 0,
      createdAt: Timestamp.now(),
    );
    firestore.collection("users").doc(currentUser.uid).set(user.toMap(user));
  }

  Future addDataToDb(auth.User currentUser, String username) async {
    try {
      user = User(
        id: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profileUrl: currentUser.photoURL,
        username: username.isNotEmpty
            ? username
            : currentUser.displayName.toLowerCase().split(' '),
        private: false,
        bio: '',
        birthdate: '',
        phone: '',
        gender: '',
        online: 0,
        createdAt: Timestamp.now(),
      );
      await firestore
          .collection("users")
          .doc(currentUser.uid)
          .set(user.toMap(user));
      return user;
    } catch (e) {
      return e.message;
    }
  }

  Future addEmailDataToDb(User currentUser, String username) async {
    try {
      user = User(
          id: currentUser.id,
          email: currentUser.email,
          name: '',
          profileUrl: '',
          username: username,
          private: false,
          bio: '',
          birthdate: '',
          phone: '',
          gender: '',
          createdAt: Timestamp.now(),
          online: 0);
      await firestore.collection("users").doc(user.id).set(user.toMap(user));
    } catch (e) {
      return e.message;
    }
  }

  Future blockUser(String currentUserId, String userId) async {
    await followersRef
        .doc(currentUserId)
        .collection('userFollowers')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await followersRef
        .doc(userId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await followingRef
        .doc(userId)
        .collection('userFollowing')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.update({'blocked': true});
      }
    });
    return await firestore
        .collection('blocked')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(userId)
        .set({'uid': userId});
  }

  Future unblockUser(String currentUserId, String userId) async {
    await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.update({'blocked': false});
      }
    });
    return await firestore
        .collection('blocked')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(userId)
        .delete();
  }

  Future addMessageToDb(
      Message message, List<String> userId, String currentUserId,
      {String groupName}) async {
    // _sendingProvider.setToLoading();

    Timestamp currentTime = message.timestamp;
    var map = message.toMap();
    userId.sort();
    await addChat(currentUserId, userId, currentTime, groupName ?? null, false);
    await addRecieversChat(
        currentUserId, userId, currentTime, groupName ?? null, false);
    for (var us = 0; us < userId.length; us++) {
      await firestore
          .collection('messages')
          .doc(userId[us])
          .collection(userId.toString())
          .doc(currentTime.millisecondsSinceEpoch.toString())
          .set(map);
    }
    // _sendingProvider.setToIdle();

    return await firestore
        .collection('messages')
        .doc(currentUserId)
        .collection(userId.toString())
        .doc(currentTime.millisecondsSinceEpoch.toString())
        .set(map);
  }

  Future setToTyping(String currentUserId, String userId, bool isTyping) async {
    await chatsRef
        .doc(userId)
        .collection('userChats')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.update({'receiverTyping': isTyping});
      }
    });
  }

  Stream isTyping(String currentUserId, List<User> userId) {
    var userIds = [];
    for (var us = 0; us < userId.length; us++) {
      userIds.add(userId[us].id);
    }
    userIds.reversed;
    userIds.remove(currentUserId);
    userIds.asMap().values;
    print('ISTYYYYYYPPNGG TTTTTT $userIds');
    return chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(currentUserId + userIds.toString())
        .snapshots();
  }

  Future deleteMessage(
      String userId, String currentUserId, DocumentSnapshot snapshot) async {
    return await messagesRef
        .doc(currentUserId)
        .collection(userId)
        .doc(snapshot.id)
        .delete();
  }

  Future unsendMessage(
      String userId, String currentUserId, DocumentSnapshot snapshot) async {
    await messagesRef
        .doc(userId)
        .collection(currentUserId)
        .doc(snapshot.id)
        .delete();

    return await messagesRef
        .doc(currentUserId)
        .collection(userId)
        .doc(snapshot.id)
        .delete();
  }

  DocumentReference getChatDocument({String chatfrom, String chatof}) =>
      chatsRef.doc(chatfrom).collection('userChats').doc(chatof);

  Future<void> addChat(String currentUserId, List<String> userId,
      Timestamp currentTime, String groupName, bool group) async {
    userId.sort();
    DocumentSnapshot groupChatsDoc = await getChatDocument(
            chatfrom: currentUserId, chatof: userId.toString())
        .get();
    print('THIS IS GROUP CHAT OF${userId.toString()}');

    if (!groupChatsDoc.exists) {
      var members = {
        currentUserId: 'admin',
      };
      for (var i = 0; i < userId.length; i++) {
        members[userId[i]] = 'member';
      }
      var receiversTyping = {
        currentUserId: false,
      };
      for (var i = 0; i < userId.length; i++) {
        receiversTyping[userId[i]] = false;
      }

      Chat chat = Chat(
          addedOn: currentTime,
          uid: currentUserId,
          members: members,
          groupName: groupName,
          group: group,
          receiversTyping: receiversTyping,
          archived: false,
          muted: false,
          locked: false,
          blocked: false,
          pinned: false);

      var chatMap = chat.toMap(chat);
      await getChatDocument(chatfrom: currentUserId, chatof: userId.toString())
          .set(chatMap);
    }
  }

  Future<void> addRecieversChat(String currentUserId, List<String> userId,
      Timestamp currentTime, String groupName, bool group) async {
    userId.sort();
    for (var userI in userId) {
      print('THIS USERI $userI');

      DocumentSnapshot receiversGroupChatsDoc =
          await getChatDocument(chatfrom: userI, chatof: userId.toString())
              .get();
      if (!receiversGroupChatsDoc.exists) {
        var members = {
          currentUserId: 'admin',
        };
        for (var i = 0; i < userId.length; i++) {
          members[userId[i]] = 'member';
        }
        var receiversTyping = {
          currentUserId: false,
        };
        for (var i = 0; i < userId.length; i++) {
          receiversTyping[userId[i]] = false;
        }
        Chat receiversChat = Chat(
            addedOn: currentTime,
            uid: currentUserId,
            members: members,
            groupName: groupName,
            group: group,
            blocked: false,
            locked: false,
            receiversTyping: receiversTyping,
            archived: false,
            muted: false,
            pinned: false);
        var receiversGroupChatMap = receiversChat.toMap(receiversChat);
        await getChatDocument(chatfrom: userI, chatof: userId.toString())
            .set(receiversGroupChatMap);
      }
    }
  }

  Future userNotifications(
      String currentUserId, String userId, String notification) async {
    await followingRef
        .doc(currentUserId)
        .collection('usersFollowing')
        .doc(userId)
        .update({'notifications': notification});
    return await followersRef
        .doc(currentUserId)
        .collection('usersFollowers')
        .doc(userId)
        .update({'notifications': notification});
  }

  Future muteChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'muted': true,
    });
  }

  Future unmuteChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'muted': false,
    });
  }

  Future pinChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'pinned': true,
    });
  }

  Future unpinChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'pinned': false,
    });
  }

  Future lockChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'locked': true,
    });
  }

  Future unlockChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'locked': false,
    });
  }

  Future archiveChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'archived': true,
    });
  }

  Future unarchiveChat(String currentUserId, String userId) async {
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .update({
      'archived': false,
    });
  }

  Future updateGroupName(
      String currentUserId, List<String> userId, String groupName) async {
    userId.remove(currentUserId);
    var receiverMap = {
      currentUserId: 'admin',
    };
    userId.sort();
    for (var us = 0; us < userId.length; us++) {
      receiverMap[userId[us]] = 'member';
    }
    Message message = Message(
      message: 'changed group name to "$groupName"',
      senderId: currentUserId,
      receiversId: receiverMap,
      timestamp: Timestamp.now(),
      seen: false,
      type: 'groupUpdate',
    );
    userId.add(currentUserId);
    userId.sort();

    await addMessageToDb(message, userId, currentUserId, groupName: groupName);
    for (var us = 0; us < userId.length; us++)
      await chatsRef
          .doc(userId[us])
          .collection('userChats')
          .doc(userId.toString())
          .update({
        'groupName': groupName,
      });
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId.toString())
        .update({
      'groupName': groupName,
    });
  }

  Future deleteChat(String currentUserId, String userId) async {
    await messagesRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .delete();
    return await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(userId)
        .delete();
  }

  Future<void> updateUser(User user) async {
    usersRef.doc(user.id).update({
      'name': user.name,
      'username': user.username,
      'profileUrl': user.profileUrl,
      'bio': user.bio,
      'birthdate': user.birthdate,
      'gender': user.gender,
    });
  }

  Future<void> updatePrivacy(User user, bool privacy) async {
    usersRef.doc(user.id).update({
      'private': privacy,
    });
  }

  Future<void> updateEmail(User user) async {
    usersRef.doc(user.id).update({
      'email': user.email,
    });
  }

  Future<void> updatePhone(User user) async {
    usersRef.doc(user.id).update({
      'phone': user.phone,
    });
  }

  Future<List<User>> fetchAllUsers() async {
    List<User> userList = List<User>();

    QuerySnapshot searchQuery = await firestore.collection('users').get();
    for (var i = 0; i < searchQuery.docs.length; i++) {
      userList.add(User.fromData(searchQuery.docs[i]));
    }
    return userList;
  }

  Future<QuerySnapshot> searchUser(String username) {
    Future<QuerySnapshot> users =
        usersRef.where('username', isGreaterThanOrEqualTo: username).get();
    return users;
  }

  Future<QuerySnapshot> searchFollowers(String username) {
    Future<QuerySnapshot> followers =
        followersRef.where('username', isGreaterThanOrEqualTo: username).get();
    return followers;
  }

  Future<QuerySnapshot> searchFollowing(String username) {
    Future<QuerySnapshot> following =
        followingRef.where('username', isGreaterThanOrEqualTo: username).get();
    return following;
  }

  DocumentReference getFollowerDocument({String of, String forFollower}) =>
      followersRef.doc(of).collection('userFollowers').doc(forFollower);
  DocumentReference getFollowingDocument({String of, String forFollower}) =>
      followingRef.doc(of).collection('userFollowing').doc(forFollower);

  followUser({String currentUserId, String userId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToFollowing(currentUserId, userId, currentTime);
    await addToFollower(userId, currentUserId, currentTime);
  }

  Future<void> addToFollowing(
      String currentUserId, String userId, currentTime) async {
    print('USER FOLLOWING: $currentUserId');

    DocumentSnapshot followingDoc = await getFollowingDocument(
      of: currentUserId,
      forFollower: userId,
    ).get();
    if (!followingDoc.exists) {
      Follower following = Follower(
          uid: userId, addedOn: currentTime, muted: false, blocked: false);
      var followingMap = following.toMap(following);

      await getFollowingDocument(of: currentUserId, forFollower: userId)
          .set(followingMap);
    }
  }

  Future<void> addToFollower(
      String userId, String currentUserId, currentTime) async {
    print('USER BEING FOLLOWED: $userId');
    DocumentSnapshot followerDoc = await getFollowerDocument(
      of: userId,
      forFollower: currentUserId,
    ).get();
    if (!followerDoc.exists) {
      Follower follower = Follower(
          uid: currentUserId,
          addedOn: currentTime,
          muted: false,
          blocked: false);
      var followerMap = follower.toMap(follower);

      await getFollowerDocument(of: userId, forFollower: currentUserId)
          .set(followerMap);
    }
  }

  Future<void> sendRequest({String currentUserId, String userId}) async {
    Timestamp time = Timestamp.now();
    Request requestTo = Request(uid: userId, addedOn: time);
    var requestToMap = requestTo.toMap(requestTo);
    await firestore
        .collection('sentRequests')
        .doc(currentUserId)
        .collection('userRequests')
        .doc(userId)
        .set(requestToMap);
    Request request = Request(uid: currentUserId, addedOn: time);
    var requestMap = request.toMap(request);
    return firestore
        .collection('receivedRequests')
        .doc(userId)
        .collection('userRequests')
        .doc(currentUserId)
        .set(requestMap);
  }

  Future<void> deleteRequest({String currentUserId, String userId}) async {
    await firestore
        .collection('sentRequests')
        .doc(currentUserId)
        .collection('userRequests')
        .doc(userId)
        .delete();
    return firestore
        .collection('receivedRequests')
        .doc(userId)
        .collection('userRequests')
        .doc(currentUserId)
        .delete();
  }

  Stream<QuerySnapshot> fetchReceivedRequests({String userId}) => firestore
      .collection('receivedRequests')
      .doc(userId)
      .collection('userRequests')
      .orderBy('addedOn', descending: true)
      .snapshots();
  Stream<QuerySnapshot> fetchBlocked({String userId}) => firestore
      .collection('blocked')
      .doc(userId)
      .collection('blockedUsers')
      .snapshots();
  Stream<QuerySnapshot> fetchFollowers(
          {String userId, String orderBy, String ascOrDesc}) =>
      followersRef
          .doc(userId)
          .collection('userFollowers')
          .orderBy(orderBy)
          .snapshots();
  Stream<QuerySnapshot> fetchFollowing({String userId, String orderBy}) =>
      followingRef
          .doc(userId)
          .collection('userFollowing')
          .orderBy(orderBy)
          .snapshots();

  Stream<QuerySnapshot> fetchChats({String userId}) =>
      chatsRef.doc(userId).collection('userChats').snapshots();
  Stream<DocumentSnapshot> fetchChat({String userId, List<String> chatId}) {
    chatId.sort();
    return chatsRef
        .doc(userId)
        .collection('userChats')
        .doc(chatId.toString())
        .snapshots();
  }

  Stream<QuerySnapshot> fetchLastMessage({
    String currentUserId,
    List userId,
  }) {
    userId.sort();
    return messagesRef
        .doc(currentUserId)
        .collection(userId.toString())
        .orderBy('timestamp')
        .snapshots();
  }

  void unfollowUser({String currentUserId, String userId}) {
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followersRef
        .doc(userId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> isRequest({String currentUserId, String userId}) async {
    DocumentSnapshot requestDoc = await firestore
        .collection('sentRequests')
        .doc(currentUserId)
        .collection('userRequests')
        .doc(userId)
        .get();
    return requestDoc.exists;
  }

  Future<bool> isRequestReceived({String currentUserId, String userId}) async {
    DocumentSnapshot requestDoc = await firestore
        .collection('receivedRequests')
        .doc(currentUserId)
        .collection('userRequests')
        .doc(userId)
        .get();
    return requestDoc.exists;
  }

  Future<bool> isFollowingUser({String currentUserId, String userId}) async {
    DocumentSnapshot followersDoc = await followersRef
        .doc(userId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    return followersDoc.exists;
  }

  Future<bool> isUserBlocked({String currentUserId, String userId}) async {
    DocumentSnapshot blockedDoc = await firestore
        .collection('blocked')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(userId)
        .get();
    return blockedDoc.exists;
  }

  Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('userFollowers').get();
    return followersSnapshot.docs.length;
  }

  Future<int> receiverRequestsNum(String userId) async {
    QuerySnapshot followersSnapshot = await firestore
        .collection('receivedRequests')
        .doc(userId)
        .collection('userRequests')
        .get();
    return followersSnapshot.docs.length;
  }

  Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('userFollowing').get();
    return followingSnapshot.docs.length;
  }

  Future<void> updateDisappearingViewTimes(
      Message message, String userId, String currentUserId) async {
    await messagesRef
        .doc(userId)
        .collection(currentUserId)
        .doc()
        .get()
        .then((doc) {
      // print('THIS IS DOC ID ${doc.docID}');

      if (doc.exists) {
        if (message.viewModes == 'Once' && message.viewTimes != '0') {
          return doc.data().update('viewTimes', (value) => '0');
        } else if (message.viewModes == 'View' && message.viewTimes == '2') {
          return doc.data().update('viewTimes', (value) => '1');
        } else if (message.viewModes == 'View' && message.viewTimes == '1') {
          return doc.data().update('viewTimes', (value) => '0');
        }
      }
    });
    await messagesRef
        .doc(currentUserId)
        .collection(userId)
        .doc()
        .get()
        .then((doc) {
      // print('THIS IS DOC ID ${doc}');
      if (doc.exists) {
        if (message.viewModes == 'Once' && message.viewTimes != '0') {
          return doc.data().update(
                'viewTimes',
                (value) => '0',
              );
        } else if (message.viewModes == 'View' && message.viewTimes == '2') {
          return doc.data().update('viewTimes', (value) => '1');
        } else if (message.viewModes == 'View' && message.viewTimes == '1') {
          return doc.data().update('viewTimes', (value) => '0');
        }
      }
    });
  }

  void setDisappearingImageMessage(
      String url,
      List<String> userId,
      String currentUserId,
      dynamic viewTimes,
      String viewModes,
      String groupOrNormal) async {
    Message message;
    message = Message.mediaDisappearingMessage(
        type: "disappearingImage",
        message: "Photo",
        receiversId: userId.asMap(),
        senderId: currentUserId,
        timestamp: Timestamp.now(),
        seen: false,
        photoUrl: url,
        viewTimes: viewTimes,
        viewModes: viewModes);
    var map = message.toDisappearingImageMap();

    await firestore
        .collection('messages')
        .doc(userId.single)
        .collection(currentUserId)
        .add(map);
    await firestore
        .collection('messages')
        .doc(currentUserId)
        .collection(userId.single)
        .add(map);
    Timestamp currentTime = message.timestamp;

    await addChat(currentUserId, userId, currentTime, null, false);
    await addRecieversChat(currentUserId, userId, currentTime, null, false);
  }
}

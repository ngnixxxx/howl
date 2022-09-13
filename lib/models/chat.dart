import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String uid;
  String groupName;
  bool muted, archived, pinned, blocked, group, locked;
  Timestamp addedOn;
  Map members;
  Map receiversTyping;

  Chat(
      {this.muted,
      this.archived,
      this.pinned,
      this.uid,
      this.groupName,
      this.members,
      this.locked,
      this.addedOn,
      this.receiversTyping,
      this.blocked,
      this.group});

  Map toMap(Chat chat) {
    var data = Map<String, dynamic>();
    data['userId'] = chat.uid;
    data['addedOn'] = chat.addedOn;
    data['muted'] = chat.muted;
    data['archived'] = chat.archived;
    data['members'] = chat.members;
    data['pinned'] = chat.pinned;
    data['blocked'] = chat.blocked;
    data['locked'] = chat.locked;
    data['groupName'] = chat.groupName;
    data['group'] = chat.group;
    data['receiversTyping'] = chat.receiversTyping;
    return data;
  }

  Chat.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['userId'];
    this.archived = mapData['archived'];
    this.muted = mapData['muted'];
    this.pinned = mapData['pinned'];
    this.addedOn = mapData['addedOn'];
    this.members = mapData['members'];
    this.groupName = mapData['groupName'];
    this.blocked = mapData['blocked'];
    this.locked = mapData['locked'];
    this.group = mapData['group'];
    this.receiversTyping = mapData['receiversTyping'];
  }
}

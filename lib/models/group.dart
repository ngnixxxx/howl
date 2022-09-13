import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String groupName;
  String groupPhoto;
  String createdBy;
  bool muted, archived, pinned;
  Map members;
  Map receiversTyping;
  Timestamp createdAt;

  Group({
    this.groupName,
    this.groupPhoto,
    this.createdBy,
    this.muted,
    this.archived,
    this.pinned,
    this.members,
    this.createdAt,
    this.receiversTyping,
  });
  Map toMap(Group group) {
    var data = Map<String, dynamic>();
    data['createdBy'] = group.createdBy;
    data['createdAt'] = group.createdAt;
    data['muted'] = group.muted;
    data['members'] = group.members;
    data['groupName'] = group.groupName;
    data['groupPhoto'] = group.groupPhoto;
    data['archived'] = group.archived;
    data['pinned'] = group.pinned;
    data['receiversTyping'] = group.receiversTyping;
    return data;
  }

  Group.fromMap(Map<String, dynamic> mapData) {
    this.createdBy = mapData['createdBy'];
    this.archived = mapData['archived'];
    this.muted = mapData['muted'];
    this.pinned = mapData['pinned'];
    this.createdAt = mapData['createdAt'];
    this.groupName = mapData['groupName'];
    this.groupPhoto = mapData['groupPhoto'];
    this.members = mapData['members'];
    this.receiversTyping = mapData['receiversTyping'];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Follower {
  String uid;
  Timestamp addedOn;
  bool muted;
  bool blocked;

  Follower({
    this.uid,
    this.addedOn,
    this.blocked,
    this.muted,
  });

  Map toMap(Follower follower) {
    var data = Map<String, dynamic>();
    data['userId'] = follower.uid;
    data['addedOn'] = follower.addedOn;
    data['muted'] = follower.muted;
    data['blocked'] = follower.blocked;
    return data;
  }

  Follower.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['userId'];
    this.addedOn = mapData['timestamp'];
    this.muted = mapData['muted'];
    this.blocked = mapData['blocked'];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  Map receiversId;
  String type;
  String message;
  String photoUrl;
  String viewTimes;
  String viewModes;
  bool seen;
  Timestamp timestamp;

  Message(
      {this.senderId,
      this.receiversId,
      this.type,
      this.message,
      this.timestamp,
      this.seen});

  Message.mediaMessage(
      {this.senderId,
      this.receiversId,
      this.type,
      this.message,
      this.photoUrl,
      this.timestamp,
      this.seen});
  Message.mediaDisappearingMessage(
      {this.senderId,
      this.receiversId,
      this.viewTimes,
      this.viewModes,
      this.type,
      this.message,
      this.photoUrl,
      this.timestamp,
      this.seen});

  Message.disappearingMessage(
      {this.senderId,
      this.receiversId,
      this.viewTimes,
      this.viewModes,
      this.type,
      this.message,
      this.timestamp,
      this.seen});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receivers'] = this.receiversId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['seen'] = this.seen;
    return map;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receivers'] = this.receiversId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['photoUrl'] = this.photoUrl;
    map['timestamp'] = this.timestamp;
    map['seen'] = this.seen;
    return map;
  }

  Map toDisappearingImageMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receivers'] = this.receiversId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['photoUrl'] = this.photoUrl;
    map['viewModes'] = this.viewModes;
    map['viewTimes'] = this.viewTimes;
    map['timestamp'] = this.timestamp;
    map['seen'] = this.seen;
    return map;
  }

  Map toDisappearingMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receivers'] = this.receiversId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['viewModes'] = this.viewModes;
    map['viewTimes'] = this.viewTimes;
    map['timestamp'] = this.timestamp;
    map['seen'] = this.seen;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiversId = map['receiversId'];
    this.type = map['type'];
    this.message = map['message'];
    this.photoUrl = map['photoUrl'];
    this.viewTimes = map['viewTimes'];
    this.viewModes = map['viewModes'];
    this.timestamp = map['timestamp'];
    this.seen = map['seen'];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  String uid;
  Timestamp addedOn;

  Request({this.uid, this.addedOn});

  Map toMap(Request chat) {
    var data = Map<String, dynamic>();
    data['userId'] = chat.uid;
    data['addedOn'] = chat.addedOn;
    return data;
  }

  Request.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['userId'];
    this.addedOn = mapData['addedOn'];
  }
}

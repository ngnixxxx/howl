class Blocked {
  String uid;

  Blocked({this.uid});

  Map toMap(Blocked blocked) {
    var data = Map<String, dynamic>();
    data['uid'] = blocked.uid;
    return data;
  }

  Blocked.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
  }
}

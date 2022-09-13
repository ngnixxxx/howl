class Call {
  String callerId;
  String callerUsername;
  String callerName;
  String callerPic;
  String recieverId;
  String recieverName;
  String recieverUsername;
  String recieverPic;
  String channelId;
  bool hasDialled;

  Call(
      {this.callerId,
      this.callerName,
      this.callerPic,
      this.callerUsername,
      this.recieverId,
      this.recieverName,
      this.recieverPic,
      this.recieverUsername,
      this.channelId,
      this.hasDialled});

  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap['callerId'] = call.callerId;
    callMap['callerUsername'] = call.callerUsername;
    callMap['callerName'] = call.callerName;
    callMap['callerPic'] = call.callerPic;
    callMap['recieverId'] = call.recieverId;
    callMap['recieverUsername'] = call.recieverUsername;
    callMap['recieverName'] = call.recieverName;
    callMap['recieverPic'] = call.recieverPic;
    callMap['channelId'] = call.channelId;
    callMap['hasDialled'] = call.hasDialled;

    return callMap;
  }

  Call.fromMap(Map callMap) {
    this.callerId = callMap['callerId'];
    this.callerUsername = callMap['callerUsername'];
    this.callerName = callMap['callerName'];
    this.callerPic = callMap['callerPic'];
    this.recieverId = callMap['recieverId'];
    this.recieverUsername = callMap['recieverUsername'];
    this.recieverName = callMap['recieverName'];
    this.recieverPic = callMap['recieverPic'];
    this.channelId = callMap['channelId'];
    this.hasDialled = callMap['hasDialled'];
  }
}

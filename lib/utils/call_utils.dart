import 'dart:math';

import 'package:howl/models/call.dart';
import 'package:howl/models/user.dart';
import 'package:howl/resources/call_methods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();
  static dial({User from, User to, context}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.name,
      callerUsername: from.username,
      callerPic: from.profileUrl,
      recieverId: to.id,
      recieverName: to.name,
      recieverUsername: to.username,
      recieverPic: to.profileUrl,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    // if (callMade) {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (_) => CallScreen(call: call)));
    // }
  }
}

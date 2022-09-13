import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/call.dart';
import 'package:howl/resources/call_methods.dart';
import 'package:howl/widgets/cached_image.dart';

class Answer extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  Answer({@required this.call});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            Text('Incoming...', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 50),
            CachedImage(
              call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 16),
            Text(call.callerName, style: Theme.of(context).textTheme.bodyText1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: Icon(Feather.phone_off),
                    onPressed: () async {
                      await callMethods.endCall(call: call);
                    },
                    color: Colors.redAccent),
                SizedBox(
                  width: 26,
                ),
                IconButton(
                  icon: Icon(Feather.phone),
                  color: Colors.green,
                  onPressed: ()  {
                  //TODO: Fix Call
                      // await Permissions.cameraAndMicrophonePermissionsGranted()
                      //     ? Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (_) => CallScreen(call: call),
                      //         ))
                      //     : () => showDialog(
                      //         context: context,
                      //         builder: (context) {
                      //           return CustomDialog(
                      //             title: 'Opps',
                      //             content: Text(
                      //                 'You need to open settings and grant the app permission to the device camera and microphone',
                      //                 style: Theme.of(context)
                      //                     .textTheme
                      //                     .bodyText1),
                      //             mainActionText: 'Open Settings',
                      //             function: () => PhotoManager.openSetting(),
                      //             secondaryActionText: 'Canel',
                      //             function1: () {
                      //               Navigator.pop(context);
                      //             },
                      //           );
                      //         });
                      },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

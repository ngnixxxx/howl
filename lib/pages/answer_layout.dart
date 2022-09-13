import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howl/models/call.dart';
import 'package:howl/pages/answer.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/resources/call_methods.dart';
import 'package:provider/provider.dart';

class AnswerLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  AnswerLayout({@required this.scaffold});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if ((userProvider != null && userProvider.getUser != null)) {
      print(userProvider);
      print(userProvider.getUser.id);
      return StreamBuilder<DocumentSnapshot>(
        stream: callMethods.callStream(uid: userProvider.getUser.id),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.data() != null) {
            Call call = Call.fromMap(snapshot.data.data());
            if (call.hasDialled)
              return Answer(call: call);
            else
              return scaffold;
          }
          return scaffold;
        },
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

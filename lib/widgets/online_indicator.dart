import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howl/enum/user_state.dart';
import 'package:howl/models/user.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/utils/utilities.dart';

class OnlineIndic extends StatelessWidget {
  final double height;
  final String uid;
  final AuthMethods authMethods = AuthMethods();

  OnlineIndic({this.height, this.uid});
  @override
  Widget build(BuildContext context) {
    getColor(dynamic state) {
      switch (Variables.numToState(state)) {
        case UserState.Online:
          return Colors.greenAccent.shade700;
        case UserState.Waiting:
          return Colors.greenAccent.shade100;
        default:
          return null;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: authMethods.getuserStream(uid: uid),
        builder: (context, snapshot) {
          User user;
          if (snapshot.hasData && snapshot.data != null) {
            user = User.fromMap(snapshot.data.data());
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: getColor(user?.online),
              ),
              child: user?.online == 1
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text('12m',
                          style: TextStyle(fontSize: 8, color: text)),
                    )
                  : null,
            );
          }
          return Container();
        });
  }
}

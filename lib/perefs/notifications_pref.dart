import 'package:flutter/material.dart';
import 'package:howl/pages/answer_layout.dart';

class NotificationsPrefs extends StatefulWidget {
  @override
  _NotificationsPrefsState createState() => _NotificationsPrefsState();
}

class _NotificationsPrefsState extends State<NotificationsPrefs> {
  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
          ),
        ),
        body: Container(),
      ),
    );
  }
}

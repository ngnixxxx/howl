import 'package:flutter/material.dart';
import 'package:howl/pages/answer_layout.dart';

class PrivacyPrefs extends StatefulWidget {
  @override
  _PrivacyPrefsState createState() => _PrivacyPrefsState();
}

class _PrivacyPrefsState extends State<PrivacyPrefs> {
  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text('Privacy'),
        ),
        body: Container(),
      ),
    );
  }
}

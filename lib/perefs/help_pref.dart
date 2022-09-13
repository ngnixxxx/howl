import 'package:flutter/material.dart';
import 'package:howl/pages/answer_layout.dart';

class HelpPrefs extends StatefulWidget {
  @override
  _HelpPrefsState createState() => _HelpPrefsState();
}

class _HelpPrefsState extends State<HelpPrefs> {
  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text('Help & Feeback'),
        ),
        body: Container(),
      ),
    );
  }
}

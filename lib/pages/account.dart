import 'package:flutter/material.dart';
import 'package:howl/pages/answer_layout.dart';

class AccountPage extends StatefulWidget {
  final String deactivateString;
  AccountPage({this.deactivateString});
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text('${widget.deactivateString} Account'),
        ),
      ),
    );
  }
}

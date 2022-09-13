import 'package:flutter/material.dart';
import 'package:howl/pages/answer_layout.dart';

class StoryPerfs extends StatefulWidget {
  @override
  _StoryPerfsState createState() => _StoryPerfsState();
}

class _StoryPerfsState extends State<StoryPerfs> {
  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text('Storry Settings'),
        ),
      ),
    );
  }
}

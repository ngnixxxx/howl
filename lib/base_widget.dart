import 'package:flutter/material.dart';
import 'package:howl/screen_information.dart';

class BaseWidget extends StatelessWidget {
  final Widget Function(
      BuildContext context, ScreenInformation screenInformation) builder;

  const BaseWidget({Key key, this.builder}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var screenInformation = ScreenInformation();
    return builder(context, screenInformation);
  }
}

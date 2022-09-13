import 'package:flutter/material.dart';
import 'package:howl/enum/screen_type.dart';

class ScreenInformation {
  final Orientation orientation;
  final ScreenTypes screenTypes;
  final Size screenSize;
  final Size localWidgetSize;

  ScreenInformation(
      {this.orientation,
      this.screenTypes,
      this.screenSize,
      this.localWidgetSize});

  @override
  String toString() {
    return 'Orientation: $orientation DeviceType: $screenTypes ScreenSize: $screenSize LocalSize: $localWidgetSize';
  }
}

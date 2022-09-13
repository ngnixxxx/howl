import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class BackgroundIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(child: Icon(Feather.message_circle, size: 20, color: Theme.of(context).accentColor.withOpacity(0.6),)),
       
      ],
    );
  }
}

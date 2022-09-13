import 'package:flutter/material.dart';

class CircleOptions extends StatelessWidget {
  final double size, iconSize;
  final Color color, iconColor;
  final IconData icon, icon2;
  final Function function, function1, function2;
  final EdgeInsets padding;

  const CircleOptions(
      {Key key,
      this.size,
      this.iconSize,
      this.color,
      this.iconColor,
      this.icon,
      this.icon2,
      this.function,
      this.function1,
      this.function2,
      this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,

            icon: Icon(
              Icons.arrow_forward_ios,
              color: iconColor,
              size: iconSize,
            ),
            onPressed: () => function(),
          ),
          IconButton(
            padding: EdgeInsets.zero,

            icon: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
            onPressed: () => function1(),
          ),
          IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                icon2,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: () => function2())
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.5),
        color: color,
      ),
    );
  }
}

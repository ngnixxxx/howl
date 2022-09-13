import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget icon;
  final Widget subtitle;
  final Widget trailing;
  final EdgeInsets margin;
  final bool mini;
  final bool thirdRow;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const CustomTile(
      {Key key,
      @required this.leading,
      @required this.title,
      this.icon,
      @required this.subtitle,
      this.trailing,
      this.thirdRow,
      this.margin = const EdgeInsets.all(0),
      this.mini = true,
      this.onTap,
      this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mini ? 10 : 16),
        margin: margin,
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: mini ? 10 : 16),
                padding: EdgeInsets.symmetric(vertical: mini ? 3 : 26),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        SizedBox(height: 5),
                        Row(children: [
                          icon ?? Container(),
                          subtitle,
                        ]),
                      ],
                    ),
                    trailing ?? Container(),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

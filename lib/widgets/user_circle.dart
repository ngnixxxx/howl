import 'package:flutter/material.dart';
import 'package:howl/utils/utilities.dart';
import 'package:provider/provider.dart';
import 'package:howl/providers/user_provider.dart';

class UserCircle extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;

  UserCircle({this.height, this.width, this.child});
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          shape: BoxShape.circle),
      child: child != null
          ? child
          : Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    Variables.getInitials(userProvider.getUser.name),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              ],
            ),
    );
  }
}

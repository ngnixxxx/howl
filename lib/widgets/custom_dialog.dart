import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String mainActionText;
  final String secondaryActionText;
  final Function function;
  final Function function1;

  CustomDialog(
      {this.title,
      this.content,
      this.function,
      this.mainActionText,
      this.secondaryActionText,
      this.function1});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          content,
          const SizedBox(height: 32),
          TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).buttonColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              onPressed: () {
                function();
              },
              child: Text(
                mainActionText,
                style: Theme.of(context).textTheme.bodyText2,
              )),
          const SizedBox(height: 10),
          TextButton(
              onPressed: () {
                function1();
              },
              style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20)),
              child: Text(
                secondaryActionText,
                style: Theme.of(context).textTheme.bodyText1,
              )),
        ],
      ),
    );
  }
}

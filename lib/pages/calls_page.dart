import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/pages/new_chat_page.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CallsPage extends StatefulWidget {
  final UserProvider userProvider;

  const CallsPage({Key key, this.userProvider}) : super(key: key);
  @override
  _CallsPageState createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      floatingActionButton: floatingAction(userProvider),
      body: Container(),
    );
  }

  Widget floatingAction(UserProvider userProvider) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) {
              return NewChatPage(contact: userProvider.getUser);
            });
      },
      label: Text('Call',
          style: Theme.of(context).textTheme.button.apply(
              color: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .color
                  .withOpacity(0.8))),
      icon: Icon(
        Feather.video,
        color: Theme.of(context).accentIconTheme.color.withOpacity(0.8),
      ),
    );
  }
}

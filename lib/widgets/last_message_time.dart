import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/message.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:provider/provider.dart';

class LastMessageTime extends StatelessWidget {
  final stream;

  LastMessageTime({@required this.stream});
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;
          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data());
            if (message.senderId == userProvider.getUser.id) {
              if (message.seen) {
                return const Icon(Feather.check_circle, size: 12);
              } else {
                return const SizedBox(height: 0, width: 0);
              }
            }
            if (!message.seen && message.type == 'disappearingImage') {
              return SizedBox(
                height: 35,
                width: 75,
                child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                    onPressed: () {},
                    icon: Icon(Feather.play,
                        size: 14,
                        color: Theme.of(context).accentIconTheme.color),
                    label: Text('Photo',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(fontSizeFactor: 0.8))),
              );
            } else {
              Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      shape: BoxShape.circle));
            }
            if (message.seen && message.type == 'disappearingImage') {
              return SizedBox(
                width: 75,
                height: 35,
                child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).primaryIconTheme.color),
                        padding: const EdgeInsets.all(2)),
                    onPressed: () {},
                    icon: Icon(Feather.camera,
                        size: 14,
                        color: Theme.of(context).primaryIconTheme.color),
                    label: Text('Reply',
                        overflow: TextOverflow.fade,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .apply(fontSizeFactor: 0.8))),
              );
            } else {
              const SizedBox(height: 50, width: 50);
            }
          }
          return const SizedBox(height: 50, width: 50);
        }
        return const SizedBox(height: 50, width: 50);
      },
    );
  }
}

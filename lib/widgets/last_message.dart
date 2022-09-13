import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howl/models/message.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class LastMessage extends StatelessWidget {
  final stream;

  LastMessage({@required this.stream});
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
            return Row(
              children: [
                Flexible(
                  flex: 3,
                  child: message.senderId == userProvider.getUser.id
                      ? Text('You: ${message.message}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1)
                      : Text(
                          message.type == 'text'
                              ? message.message
                              : 'Sent a ${message.message}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: message.seen
                              ? Theme.of(context).textTheme.bodyText1
                              : Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .apply(fontWeightDelta: 300)),
                ),
                SizedBox(width: 6),
                Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        shape: BoxShape.circle)),
                SizedBox(width: 6),
                Flexible(
                  flex: 1,
                  child: Text(
                      timeago.format(message.timestamp.toDate(),
                          locale: 'en_short'),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ],
            );
          }
          return Text('No messages yet',
              style: Theme.of(context).textTheme.bodyText1);
        }
        return Text('No messages',
            style: Theme.of(context).textTheme.bodyText1);
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/models/request.dart';
import 'package:howl/models/user.dart';
import 'package:howl/resources/auth_methods.dart';


class LastRequest extends StatelessWidget {
  final stream;
  LastRequest({Key key, this.stream}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AuthMethods _authMethods = AuthMethods();
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;
          if (docList.isNotEmpty) {
            Request request = Request.fromMap(docList.last.data());
            return FutureBuilder(
                future: _authMethods.getUserWithId(request.uid),
                builder: (context, snapshot) {
                  User user = snapshot.data;
                  return CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          CachedNetworkImageProvider(user?.profileUrl));
                });
          }
          return CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: Icon(Feather.plus,
                color: Theme.of(context).primaryIconTheme.color),
          );
        }
        return CircleAvatar(
          radius: 24,
          backgroundColor: Colors.transparent,
          child: Icon(Feather.plus,
              color: Theme.of(context).primaryIconTheme.color),
        );
      },
    );
  }
}

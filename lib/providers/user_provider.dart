import 'package:flutter/cupertino.dart';
import 'package:howl/models/user.dart';
import 'package:howl/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  User _user;
  AuthMethods _authMethods = AuthMethods();

  User get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();

    _user = user;

    notifyListeners();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:howl/enum/user_state.dart';
import 'package:howl/models/user.dart' as user;
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:howl/utils/utilities.dart';

class AuthMethods {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<auth.User> getCurrentUser() async {
    auth.User currentUser;
    currentUser = currentUser;
    return currentUser;
  }

  // Future<bool> isUserLogginIn() async {
  //   var user = await getCurrentUser(currentUser);
  //   await getCurrentUser(user);
  //   return user != null;
  // }

  Future getUser(String uid) async {
    try {
      var userData = await usersRef.doc(uid).get();
      return user.User.fromData(userData);
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future<user.User> getUserDetails() async {
    auth.User currentUser = await getCurrentUser();
    DocumentSnapshot doc = await usersRef.doc(currentUser.uid).get();

    return user.User.fromData(doc);
  }

  Future signIn() async {
    try {
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication _signInAuth =
          await _signInAccount.authentication;
      auth.AuthCredential credential = auth.AuthCredential(
          providerId: _signInAuth.idToken,
          signInMethod: _signInAuth.accessToken);

      var authResult = await _auth.signInWithCredential(credential);
      return authResult;
    } on PlatformException catch (ex) {
      return ex.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future emailRegister(
      {@required String email,
      @required String password,
      @required String username}) async {
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return authResult != null;
    } catch (e) {
      return e.message;
    }
  }

  Future emailSignIn(
      {@required String email, @required String password}) async {
    try {
      var authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return authResult != null;
    } catch (e) {
      print('THIS IS EMAIL SIGN IN ERROR ${e.message}');
      return e.message;
    }
  }

  Future<void> verifyPhone(
      String phoneNo, verificationId, bool sent, String code) async {
    final auth.PhoneVerificationCompleted verified = (a) async {
      await _auth.signInWithPhoneNumber(phoneNo, auth.RecaptchaVerifier());
    };

    final auth.PhoneVerificationFailed verificationFailed =
        (auth.FirebaseAuthException authException) {
      print('${authException.message}');
    };

    final auth.PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      verificationId = verId;
      sent = true;
    };

    final auth.PhoneCodeAutoRetrievalTimeout retrivalTimeout = (String verId) {
      verificationId = verId;
    };
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: null);
  }

  Future<bool> authanticateUser(auth.User user, String username) async {
    QuerySnapshot result = await firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<bool> usernameExists(String username) async {
    QuerySnapshot usernameResult =
        await usersRef.where("username", isEqualTo: username).get();
    final List<DocumentSnapshot> docs = usernameResult.docs;

    return docs.length == 0 ? true : false;
  }

  Future<bool> userExists(auth.User user) async {
    DocumentSnapshot usernameResult =
        await firestore.collection('users').doc(user.uid).get();
    if (!usernameResult.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> authanticatePhoneUser(auth.User user, username) async {
    QuerySnapshot result = await firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .where("phone", isEqualTo: user.phoneNumber)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<bool> authanticateEmailUser(result, String username) async {
    QuerySnapshot result = await firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      return e.message;
    }
  }

  Future<user.User> getUserWithId(String userId) async {
    try {
      DocumentSnapshot userDocSnapshot = await usersRef.doc(userId).get();
      return user.User.fromMap(userDocSnapshot.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<user.User>> getUsersWithId(List<String> userId) async {
    try {
      List<user.User> users = [];
      for (var userById = 0; userById < userId.length; userById++) {
        DocumentSnapshot userDocSnapshot =
            await usersRef.doc(userId[userById]).get();
        users.add(user.User.fromMap(userDocSnapshot.data()));
      }
      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setUserState({@required String userId, @required UserState userState}) {
    dynamic stateNum = Variables.stateToNum(userState);

    usersRef.doc(userId).update({'online': stateNum});
  }

  Stream<DocumentSnapshot> getuserStream({@required String uid}) =>
      usersRef.doc(uid).snapshots();
}

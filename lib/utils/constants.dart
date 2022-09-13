import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// Light Theme
const Color accent = Color.fromARGB(255,  73, 37, 64);
const Color primary = Color.fromARGB(255, 228, 227, 229);
const Color text = Color.fromARGB(255,  73, 37, 64);
const Color secondary = Color.fromARGB(255, 203, 203, 207);

// Dark Theme
const Color secondaryDark = Color.fromARGB(255, 141, 137, 163);
const Color accentDark = Color.fromARGB(255, 246, 234, 140);
const Color primaryDark = Color.fromARGB(255, 73, 37, 64);
const Color textDark = Color.fromARGB(255, 228, 227, 229);

//Midnight Theme
const Color antarctic_blue = Color.fromARGB(255, 44, 61, 99);
const Color accentMidnight = Color.fromARGB(255, 226, 243, 245);
const Color primaryMidnight = Color.fromARGB(255, 0, 0, 0);
const Color oilySteel = Color.fromARGB(255, 155, 168, 168);
const Color articFox = Color.fromARGB(255, 235, 238, 231);
const Color babyPowder = Color.fromARGB(255, 247, 248, 243);
const Color brook_green = Color.fromARGB(255, 173, 220, 202);
const Color pelorous = Color.fromARGB(255, 59, 176, 186);

const String imageNotAvailable =
    'https://firebasestorage.googleapis.com/v0/b/moon-sun-curse.appspot.com/o/no-img.png?alt=media&token=72248e1d-8d8c-4c2f-806c-3ef3b824879b';

final _firestore = FirebaseFirestore.instance;

final usersRef = _firestore.collection('users');
final messagesRef = _firestore.collection('messages');
final chatsRef = _firestore.collection('chats');

final storageRef = FirebaseStorage.instance.ref();
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');

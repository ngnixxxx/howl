import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:howl/models/user.dart';
import 'package:howl/providers/disappearing_image_provider.dart';
import 'package:howl/utils/constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'firebase_methods.dart';
import 'package:path_provider/path_provider.dart';

class StorageMethods {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  User user;

  Future<String> uploadProfileImage(
      String url, File imageFile, String username) async {
    String photoId = username;
    File image = await compressImage(photoId, imageFile);
    String downloadUrl;

    if (url.isNotEmpty) {
      RegExp exp = RegExp(r'profile_(.*).jpg');
      photoId = exp.firstMatch(url)[1];
    }
    UploadTask uploadTask = storageRef
        .child('images/users/$username/profile_$photoId.jpg')
        .putFile(image);
    await uploadTask.then((res) async {
      downloadUrl = await res.ref.getDownloadURL();
    });

    return downloadUrl;
  }

  Future<String> uploadImageToStorage(File image, String username) async {
    try {
      String url;
      UploadTask uploadTask = storageRef
          .child(
              'chats/$username/disappearing_${DateTime.now().microsecondsSinceEpoch}.jpg')
          .putFile(image);
      await uploadTask.then((res) async {
        url = await res.ref.getDownloadURL();
      });
      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadDisappearingImage({
    String username,
    File image,
    List<String> userId,
    String currentUserId,
    String viewTimes,
    String viewModes,
    DisappearingImageProvider imageProvider,
    String groupOrNormal,
  }) async {
    imageProvider.setToLoading();
    String url = await uploadImageToStorage(image, username);

    imageProvider.setToIdle();

    _firebaseMethods.setDisappearingImageMessage(
        url, userId, currentUserId, viewTimes, viewModes, groupOrNormal);
  }

  Future<File> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImageFile;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String username;
  String email;
  String profileUrl;
  String bio;
  String gender;
  String birthdate;
  dynamic online;
  bool private;
  String phone;
  Timestamp createdAt;

  User({
    this.id,
    this.username,
    this.name,
    this.email,
    this.bio,
    this.profileUrl,
    this.phone,
    this.online,
    this.birthdate,
    this.gender,
    this.private,
    this.createdAt,
  });

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.id;
    data['username'] = user.username;
    data['name'] = user.name;
    data['email'] = user.email;
    data['bio'] = user.bio;
    data['profileUrl'] = user.profileUrl;
    data['phone'] = user.phone;
    data['online'] = user.online;
    data['birthdate'] = user.birthdate;
    data['gender'] = user.gender;
    data['private'] = user.private;
    data['createdAt'] = user.createdAt;

    return data;
  }

  User.fromMap(Map<String, dynamic> mapData)
      : id = mapData['uid'],
        username = mapData['username'],
        name = mapData['name'] ?? '',
        email = mapData['email'] ?? '',
        bio = mapData['bio'] ?? '',
        profileUrl = mapData['profileUrl'] ?? '',
        phone = mapData['phone'] ?? '',
        online = mapData['online'],
        private = mapData['private'] ?? false,
        birthdate = mapData['birthdate'] ?? '',
        gender = mapData['gender'] ?? '',
        createdAt = mapData['createdAt'];
  Map<String, dynamic> toData() {
    return {
      'uid': id,
      'username': username,
      'name': name,
      'email': email,
      'bio': bio,
      'profileUrl': profileUrl,
      'phone': phone,
      'online': online,
      'private': private,
      'birthdate': birthdate,
      'gender': gender,
      'createdAt': createdAt,
    };
  }

  factory User.fromData(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      username: doc['username'],
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      bio: doc['bio'] ?? '',
      profileUrl: doc['profileUrl'] ?? '',
      phone: doc['phone'] ?? '',
      online: doc['online'],
      private: doc['private'] ?? false,
      birthdate: doc['birthdate'] ?? '',
      gender: doc['gender'] ?? '',
      createdAt: doc['createdAt'],
    );
  }
}

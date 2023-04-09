import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uId;
  final String email;
  final String? name;
  //final String? phone;
  final String? rol;
  final String? uidSupervised;
  final String? emailSup;
  final String? image;


  UserModel({
    required this.uId,
    required this.email,
    this.name,
    this.rol,
    this.uidSupervised,
    this.emailSup,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'email': email,
      'name': name ?? '',
      //'phone': phone ?? '',
      'rol': rol ?? '',
      'uidSupervised': uidSupervised ?? '',
      'emailSup': emailSup ?? '',
      'image': image ?? '',
    }..removeWhere((key, value) => value == null);
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uId: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      //phone: map['phone'] ?? '',
      rol: map['rol'] ?? '',
      uidSupervised: map['uidSupervised'] ?? '',
      emailSup: map['emailSup'] ?? '',
      image: map['image'] ?? '',
    );
  }

  /// Google Factory
  factory UserModel.fromUserCredential(User user, String? rol, String? name, String? uidSupervised, String? emailSup) {
    return UserModel(
      uId: user.uid,
      email: user.email ?? '',
      name: name ?? user.displayName?.split(' ').first, //?? '',
      //phone: user.phoneNumber ?? '',
      rol: rol ?? '',
      uidSupervised: uidSupervised ?? '',
      emailSup: emailSup ?? '',
      image: user.photoURL ?? '',
    );
  }

  factory UserModel.setSupervised(User user, String? rol, String? name, String? uidSupervised, String? emailSup) {
    return UserModel(
      uId: user.uid,
      email: user.email ?? '',
      name: name ?? user.displayName?.split(' ').first, //?? '',
      //phone: user.phoneNumber ?? '',
      rol: rol ?? '',
      uidSupervised: uidSupervised ?? '',
      emailSup: emailSup ?? '',
      image: user.photoURL ?? '',
    );
  }

  UserModel copyWith({
    String? uId,
    String? name,
    String? email,
    String? rol,
    String? uidSupervised,
    String? emailSup,
    String? image,
    String? phone,
  }) {
    return UserModel(
      uId: uId ?? this.uId,
      name: name ?? this.name,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      uidSupervised: uidSupervised ?? this.uidSupervised,
      emailSup: emailSup ?? this.emailSup,
      image: image ?? this.image,
      //phone: phone ?? this.phone,
    );
  }
}

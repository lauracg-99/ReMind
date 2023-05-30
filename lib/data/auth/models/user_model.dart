import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:remind/data/auth/models/supervised.dart';

class UserModel {
  final String uId;
  final String email;
  final String? name;
  final String? rol;
  final String? image;
  final String? lastUIDSup;
  final String? lastEmailSup;
  final List<Supervised>? supervisados;

  UserModel({
    required this.uId,
    required this.email,
    this.name,
    this.rol,
    required this.image,
    this.lastUIDSup,
    this.lastEmailSup,
    this.supervisados,
  });

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'email': email,
      'name': name ?? '',
      'rol': rol ?? '',
      'image': image ?? '',
      'lastUIDSup': lastUIDSup ?? '',
      'lastEmailSup': lastEmailSup ?? '',
      'supervisados': supervisados?.map((user) => user.toMap()).toList(),

    }..removeWhere((key, value) => value == null);
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String? documentId) {
    return UserModel(
      uId: map['uId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      rol: map['rol'] ?? '',
      image: map['image'] ?? '',
      supervisados: (map['supervisados'] as List<dynamic>?)
          ?.map((user) => Supervised.fromMap(user))
          .toList(),
      lastUIDSup: map['lastUIDSup'] ?? '',
      lastEmailSup: map['lastEmailSup'] ?? '',
    );
  }

  /// Google Factory
  factory UserModel.fromUserCredential(User user, String? rol, String? name,
  List<Supervised>? supervisados, String? lastEmailSup, String? lastUIDSup) {
    return UserModel(
      uId: user.uid,
      email: user.email ?? '',
      name: name ?? user.displayName?.split(' ').first, //?? '',
      rol: rol ?? '',
      image: user.photoURL ?? '',
      supervisados: supervisados ?? [],
      lastUIDSup: lastUIDSup ?? '',
      lastEmailSup: lastEmailSup ?? '',
    );
  }


  UserModel copyWith({
    String? uId,
    String? name,
    String? email,
    String? rol,
    String? image,
    String? phone,
    String? lastUIDSup,
    String? lastEmailSup,
    List<Supervised>? supervisados,

  }) {
    return UserModel(
      uId: uId ?? this.uId,
      name: name ?? this.name,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      image: image ?? this.image,
      lastUIDSup: lastUIDSup ?? this.lastUIDSup,
      lastEmailSup: lastEmailSup ?? this.lastEmailSup,
      supervisados: supervisados ?? this.supervisados,
      //phone: phone ?? this.phone,
    );
  }
}

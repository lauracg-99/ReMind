import 'dart:developer';

import 'package:remind/data/auth/models/user_model.dart';

class Supervised {
  final String uId;
  final String email;
  final String? name;
  final String? rol;
  final String? image;
  final String? selected;


  Supervised({
    required this.uId,
    required this.email,
    this.name,
    this.rol,
    required this.image,
    this.selected,
  });

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'email': email,
      'name': name ?? '',
      'rol': rol ?? '',
      'image': image ?? '',
      'selected': selected ?? ''
    }
      ..removeWhere((key, value) => value == null);
  }

  factory Supervised.fromMap(Map<String, dynamic> map) {
    return Supervised(
      uId: map['uId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      rol: map['rol'] ?? '',
      image: map['image'] ?? '',
      selected: map['selected'] ?? ''
    );
  }

  /// Google Factory
  factory Supervised.fromUserModel(UserModel user, String? selected) {
    return Supervised(
      uId: user.uId,
      email: user.email,
      name: user.name ?? '',
      rol: user.rol ?? '',
      image: user.image ?? '',
      selected: selected
    );
  }

  Supervised copyWith({
     /*String? uId,
     String? email,
     String? name,
     String? rol,
     String? image,
     String? selected,*/
    required Supervised supervised
  }) {
    return Supervised(
      uId: supervised.uId,
      name: supervised.name ?? this.name,
      email: supervised.email,
      rol: supervised.rol ?? this.rol,
      image: supervised.image ?? this.image,
      selected: supervised.selected ?? this.selected
    );
  }
}
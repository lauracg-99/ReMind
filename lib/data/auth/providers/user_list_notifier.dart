
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import 'package:remind/data/auth/models/supervised.dart';
import 'package:remind/data/auth/models/user_model.dart';
import 'package:rxdart/rxdart.dart';

import 'auth_provider.dart';


final userListProvider = StreamProvider<List<UserModel>>((ref) {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('users');
  return query.snapshots().map((snapshot) {
    // Mapea los documentos a una lista de usuarios
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(),'')).toList();});
});

final petitionstProvider = StreamProvider<List<Solicitud>>((ref) {
  return ref.watch(authRepoProvider).getPetitionsStream();
});

final supervisoresProvider = StreamProvider<UserModel>((ref) {
  return ref.watch(authRepoProvider).getSupervisedStream();
});

final petitionstProviderAll = StreamProvider<List<Solicitud>>((ref) {
  return ref.watch(authRepoProvider).getPetitionsStreamAll();
});

final usersStream = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(authRepoProvider).getUsersStream();
});




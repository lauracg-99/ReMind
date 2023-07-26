import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/dependencies.dart';
import 'package:remind/common/storage_keys.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import 'package:remind/data/auth/models/supervised.dart';
import 'package:remind/data/auth/models/user_model.dart';
import 'package:remind/domain/auth/repo/user_repo.dart';
import '../../error/exceptions.dart';
import '../../error/failures.dart';
import '../../firebase/repo/firebase_caller.dart';
import '../../firebase/repo/firestore_paths.dart';
import '../../firebase/repo/i_firebase_caller.dart';
import '../providers/auth_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

class AuthRepo {
  AuthRepo(this.ref){
    _firebaseCaller = ref.watch(firebaseCaller);
    _userRepo = ref.watch(userRepoProvider);
  }

  final Ref ref;
  late IFirebaseCaller _firebaseCaller;
  late UserRepo _userRepo;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var dependencies = Dependencies();

  Future<Either<Failure, UserModel>> signInWithEmailAndPassword( {required String email, required String password,}) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      log('*** auth_repo userCredential.user?.uid');
      log(userCredential.toString());
      dependencies.write(StorageKeys.uidUsuario, userCredential.user?.uid);
      dependencies.write(StorageKeys.email, email);
      dependencies.write(StorageKeys.passw, password);
      dependencies.write(StorageKeys.reset, StorageKeys.falso);

      UserModel usuario = await _userRepo.getDatosUsuario(dependencies.read(StorageKeys.uidUsuario));
      if(usuario.rol == StorageKeys.SUPERVISOR) {
        dependencies.write(StorageKeys.lastUIDSup, usuario.lastUIDSup);
        dependencies.write(StorageKeys.lastEmailSup, usuario.lastEmailSup);
      }

      return Right(usuario);

    } on FirebaseAuthException catch (errorMessage) {
      return Left(ServerFailure(message: errorMessage));

    } catch (e) {
      log(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      return Left(ServerFailure(message: errorMessage));
    }
  }

  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      log('*** auth_repo userCredential.user?.uid');
      log(userCredential.toString());
      dependencies.write(StorageKeys.uidUsuario, userCredential.user?.uid);
      dependencies.write(StorageKeys.email, user?.email);
      dependencies.write(StorageKeys.reset, StorageKeys.falso);

      UserModel usuario = await _userRepo.getDatosUsuario(dependencies.read(StorageKeys.uidUsuario));
      if(usuario.rol == StorageKeys.SUPERVISOR) {
        dependencies.write(StorageKeys.lastUIDSup, usuario.lastUIDSup);
        dependencies.write(StorageKeys.lastEmailSup, usuario.lastEmailSup);
      }

      return Right(usuario);

    } on FirebaseAuthException catch (errorMessage) {
      return Left(ServerFailure(message: errorMessage));

    } catch (e) {
      log(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      return Left(ServerFailure(message: errorMessage));
    }
  }



  Stream<List<UserModel>> getUsersStream() {
    return FirebaseFirestore.instance.collection('users').get().asStream().map((querySnapshot) {
      return querySnapshot.docs.map((doc)
      => UserModel.fromMap(doc.data(), '')).toList();
    });
  }

  Stream<List<Solicitud>> getPetitionsStream() {
    return  _firebaseCaller.collectionStream<Solicitud>(
      //uid de usuario
      path: FirestorePaths.userPetitionCollection(GetStorage().read(StorageKeys.uidUsuario)),
      queryBuilder: (query) => query
          .where("estado", isEqualTo: 'pendiente'),
      builder: (snapshotData, snapshotId) {
        var solicitud =  Solicitud.fromMap(snapshotData!);
        solicitud.id = snapshotId;
        return solicitud;

      },
    );
  }

/*  Stream<List<Supervised>> getSupervisedStream() {
    log('${FirestorePaths.userDocumentSupervisados(GetStorage().read(StorageKeys.uidUsuario))}');
    return  _firebaseCaller.collectionStream<Supervised>(
      //uid de usuario
      path: FirestorePaths.userDocumentSupervisados(GetStorage().read(StorageKeys.uidUsuario)),
      builder: (snapshotData, snapshotId) {
        var supervised =  Supervised.fromMap(snapshotData!);
        return supervised;

      },
    );
  }*/

  Stream<UserModel> getSupervisedStream() {
    return  _firebaseCaller.documentStream<UserModel>(
      //uid de usuario
      path: FirestorePaths.userDocument(GetStorage().read(StorageKeys.uidUsuario)),
      builder: (snapshotData, snapshotId) {
        return UserModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<Solicitud>> getPetitionsStreamAll() {
    return  _firebaseCaller.collectionStream<Solicitud>(
      //uid de usuario
      path: FirestorePaths.userPetitionCollection(GetStorage().read(StorageKeys.uidUsuario)),
      builder: (snapshotData, snapshotId) {
        var solicitud =  Solicitud.fromMap(snapshotData!);
        solicitud.id = snapshotId;
        return solicitud;

      },
    );
  }

  Future<Either<Failure, UserModel>> createUserWithEmailAndPassword({
        required String email,
        required String password,
        required String name,
        required String rol,
      }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      log(userCredential.toString());
      dependencies.write(StorageKeys.uidUsuario, userCredential.user?.uid);
      dependencies.write(StorageKeys.email, email);
      dependencies.write(StorageKeys.passw, password);
      dependencies.write(StorageKeys.rol, rol);

      if(rol == StorageKeys.SUPERVISOR){
        dependencies.write(StorageKeys.lastEmailSup, '');
        dependencies.write(StorageKeys.lastUIDSup, '');
        //dependencies.writeListUsers(StorageKeys.supervisados, []);
      }
      return Right(
          UserModel.fromUserCredential(userCredential.user!,rol, name, [], '', '')
      );

    } on FirebaseAuthException catch (errorMessage) {
      return Left(ServerFailure(message: errorMessage.toString()));

    } catch (e) {
      log(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      return Left(ServerFailure(message: errorMessage));
    }
  }

  //auth.sendPasswordResetEmail(email: logic.emailController.text.trim());

  Future<Either<Failure, bool>> sendPasswordResetEmail({required String email,}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return const Right(true);
    } on FirebaseAuthException catch (errorMessage) {
      return Left(ServerFailure(message: errorMessage));
    } catch (e) {
      log(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      return Left(ServerFailure(message: errorMessage));
    }
  }


  isVerifiedEmail() async {
    return await FirebaseAuth.instance.currentUser!.reload();
  }

  deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  Stream<bool?> isEmailverified() async* {
    bool? enabled;
    while (true) {
      try {
        await FirebaseAuth.instance.currentUser!.reload();
        bool? isEnabled = FirebaseAuth.instance.currentUser?.emailVerified;
        if (enabled != isEnabled) {
          enabled = isEnabled;
          yield enabled;
        }
      }
      catch (error) {}
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Future<Either<Failure, bool>> sendEmailVerification(BuildContext context,) async {
    try {
      AuthState.loading();
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      return const Right(true);
    } on FirebaseAuthException catch (e) {
      final errorMessage = Exceptions.firebaseAuthErrorMessage(context, e);
      return Left(ServerFailure(message: errorMessage));
    } catch (e) {
      log(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      return Left(ServerFailure(message: errorMessage));
    }
  }

  Future<Either<Failure, bool>> enviarEmailSupervisor(BuildContext context,) async {
    try {
      AuthState.loading();
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      return const Right(true);
    } on FirebaseAuthException catch (e) {
      final errorMessage = Exceptions.firebaseAuthErrorMessage(context, e);
      return Left(ServerFailure(message: errorMessage));
    } catch (e) {
      log(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      return Left(ServerFailure(message: errorMessage));
    }
  }

  //cerrar sesion
  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log(e.toString());
    }
  }

}

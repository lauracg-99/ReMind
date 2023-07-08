import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/storage_keys.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../data/auth/providers/auth_provider.dart';
import '../../../data/auth/repo/auth_repo.dart';
import '../../../data/error/failures.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../providers/main_core_provider.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../utils/dialogs.dart';
import 'auth_state.dart';

final authProvider =
StateNotifierProvider.autoDispose<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final bossValidProvider = StreamProvider<bool?>((ref) {
    return ref.watch(authRepoProvider).isEmailverified();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(const AuthState.available()) {
    _mainCoreProvider = ref.watch(mainCoreProvider);
    _authRepo = ref.watch(authRepoProvider);
    _userRepo = ref.watch(userRepoProvider);
  }


  final Ref ref;
  late MainCoreProvider _mainCoreProvider;
  late AuthRepo _authRepo;
  late UserRepo _userRepo;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  static bool supervisor = false;


  setSupervisor(bool set){
    supervisor = set;
  }

  Future<Either<Failure, bool>> signInWithEmailAndPassword({
        required String email,
        required String password,
      }) async {
    state = const AuthState.loading();
    final result = await _authRepo.signInWithEmailAndPassword(email: email, password: password,);
    return await result.fold(
          (failure) {
            state = AuthState.error(errorText: failure.message);
            return Left(failure);
          },
          (user) async {
            state = const AuthState.available();
            UserModel userModel = user;
            await GetStorage().erase();
            var getStorage = GetStorage();
            getStorage.write(StorageKeys.uidUsuario, user.uId);
            getStorage.write(StorageKeys.email, email);
            getStorage.write(StorageKeys.passw, password);
            getStorage.write(StorageKeys.rol, user.rol);

            if(user.rol == StorageKeys.SUPERVISOR){
              getStorage.write(StorageKeys.lastEmailSup, user.lastEmailSup);
              getStorage.write(StorageKeys.lastUIDSup, user.lastUIDSup);
              //getStorage.write(StorageKeys.supervisados, user.supervisados);
            }
            return const Right(true);
      },
    );
  }

  Future<void> deleteGoogleAccount() async {
    try {
      await _googleSignIn.disconnect();
      // Opcionalmente, puedes revocar los tokens de acceso con:
      // await _googleSignIn.disconnect().then((_) => _googleSignIn.signOut());
      print('Cuenta de Google eliminada exitosamente.');
    } catch (error) {
      print('Error al eliminar la cuenta de Google: $error');
    }
  }

  Future<Either<Failure, bool>> signInWithGoogle() async {

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!
          .authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      final User? user = userCredential.user;


        final AdditionalUserInfo? additionalUserInfo = userCredential
            .additionalUserInfo;
        final bool isNewUser = additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          // El usuario es nuevo, solicitar información adicional para el registro
          GetStorage().write('firstTimeLogIn', true);
          var getStorage = GetStorage();
          //getStorage.write("user", user);
          getStorage.write(StorageKeys.uidUsuario, user?.uid);
          getStorage.write(StorageKeys.email, user?.email);
          getStorage.write(StorageKeys.name,  user?.displayName);


          return Right(false);
        } else {
          // El usuario ya ha iniciado sesión previamente, proceder con el flujo normal
          // Resto de tu lógica después de iniciar sesión
          GetStorage().write('firstTimeLogIn', false);
          state = const AuthState.loading();
          final result = await _authRepo.signInWithGoogle();
          return await result.fold(
                (failure) {
                  state = AuthState.error(errorText: failure.message);
                  return Left(failure);
                },
                (user) async {
              state = const AuthState.available();
              UserModel userModel = user;
              var getStorage = GetStorage();
              getStorage.write(StorageKeys.uidUsuario, user.uId);
              getStorage.write(StorageKeys.email, user.email);
              getStorage.write(StorageKeys.rol, user.rol);

              if (user.rol == StorageKeys.SUPERVISOR) {
                getStorage.write(StorageKeys.lastEmailSup, user.lastEmailSup);
                getStorage.write(StorageKeys.lastUIDSup, user.lastUIDSup);
              }
              return const Right(true);
            },
          );
      }
  }

  Future<User?> getCurrentUser() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    return user;
  }



  Future<Either<Failure, bool>> createUserWithEmailAndPassword( {
        required String email,
        required String password,
        required String name,
        required String rol
      }) async {
    state = const AuthState.loading();
      final result = await _authRepo.createUserWithEmailAndPassword(email: email, password: password, name: name, rol: rol);
      return await result.fold(
        (failure) {
          state = AuthState.error(errorText: failure.message);
          return Left(failure);
        },
        (user) async {

          state = const AuthState.available();
          await GetStorage().erase();
          await  _userRepo.setUserData(user);
          var getStorage = GetStorage();
          getStorage.write(StorageKeys.uidUsuario, user.uId);
          getStorage.write(StorageKeys.email, email);
          getStorage.write(StorageKeys.passw, password);
          getStorage.write(StorageKeys.rol, user.rol);

          if(user.rol == StorageKeys.SUPERVISOR){
            getStorage.write(StorageKeys.lastEmailSup, user.lastEmailSup);
            getStorage.write(StorageKeys.lastUIDSup, user.lastUIDSup);
            //getStorage.write(StorageKeys.supervisados, user.supervisados);
          }
          //await submitRegister(context, userModel);
          return const Right(true);
        },

      );
  }

  Future<Either<Failure, bool>> sendPasswordResetEmail({required String email}) async {
    state = const AuthState.loading();
    final result = await _authRepo.sendPasswordResetEmail(email: email);
    return result.fold(
          (failure) {
        state = AuthState.error(errorText: failure.message);
        return Left(failure);
        },
        (done){
          return const Right(true);
        }
    );

  }

}

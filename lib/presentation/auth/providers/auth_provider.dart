import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
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

/*
  enviarEmailVerification(BuildContext context) async {
    state = const AuthState.loading();
   // NavigationService.removeAllFocus(context);
    final result = await _authRepo.sendEmailVerification(context,);
    result.fold(
            (failure) {
              state = AuthState.error(errorText: failure.message);
              AppDialogs.showErrorDialog(context, message: failure.message);
            },
            (done){
              state = AuthState.available();
         //     navigationToCheckScreen(context);
        }
    );
  }

  void enviarEmailSupervisor(BuildContext context) async {
    state = const AuthState.loading();
    // NavigationService.removeAllFocus(context);
    final result = await _authRepo.sendEmailVerification(context,);
    result.fold(
            (failure) {
          state = AuthState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
        },
            (done){
          state = AuthState.available();
          //navigationToCheckScreen(context);
        }
    );
  }
*/

  /*openCollection(UserModel userModel) async {
    await _mainCoreProvider.openCollection(userModel);
  }*/

/*  Future submitRegister(BuildContext context, UserModel userModel) async {

    final result = await _mainCoreProvider.setUserToFirebase(userModel);
    await result.fold(
          (failure) {
        state = AuthState.error(errorText: failure.message);
        AppDialogs.showErrorDialog(context, message: failure.message);
      },
        (isSet) async {
          if((userModel.rol == StorageKeys.SUPERVISOR)) {
          await _authRepo.sendEmailVerification(context);
        } else{
            AuthState.available();
          }

        if (GetStorage().read('rol') != 'supervisor') {
          setSupervisor(false);
        } else {
          setSupervisor(true);
        }
        (!supervisor)
          ? navigationToHomeScreen(context)
          : navigationToCheckScreen(context);
      },
    );
  }


  navigationToCheckScreen(BuildContext context) {
    NavigationService.pushReplacementAll(
      context,
      isNamed: true,
      page: RoutePaths.verifyEmail,
    );
  }

  navigationToLogin(BuildContext context) {
    NavigationService.pushReplacementAll(
      context,
      isNamed: true,
      page: RoutePaths.authLogin,
    );
  }*/
}

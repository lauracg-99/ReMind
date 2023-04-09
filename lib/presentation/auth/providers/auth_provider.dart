import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../data/auth/providers/auth_provider.dart';
import '../../../data/auth/repo/auth_repo.dart';
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

  signInWithEmailAndPassword(
      BuildContext context, {
        required String email,
        required String password,
      }) async {
    state = const AuthState.loading();
    NavigationService.removeAllFocus(context);
    final result = await _authRepo.signInWithEmailAndPassword(
      context,
      email: email,
      password: password,
    );
    await result.fold(
          (failure) {
        state = AuthState.error(errorText: failure.message);
        AppDialogs.showErrorDialog(context, message: failure.message);
      },
          (user) async {
            state = const AuthState.available();

        UserModel userModel = user;
        await GetStorage().erase();
        var getStorage = GetStorage();
        getStorage.write('uidUsuario', user.uId);
        getStorage.write('email', email);
        getStorage.write('passw', password);
        getStorage.write('rol', user.rol);

        // TODO: nombre
        //subscribeUserToTopic();
        navigationToHomeScreen(context);
        //await submitLogin(context, userModel);
      },
    );
  }


  signSupervisedIn(
      BuildContext context, {
        required String emailSupervised,
        required String passwordSupervised,
      }) async {
    state = const AuthState.loading();
    NavigationService.removeAllFocus(context);
    final result = await _authRepo.signSupervisedIn(context,
        emailSupervised: emailSupervised,
      passwordSupervised: passwordSupervised
    );
    await result.fold(
          (failure) {
        state = AuthState.error(errorText: failure.message);
        AppDialogs.showErrorDialog(context, message: failure.message);
      },
          (user) async {
        UserModel userModel = user;

        _mainCoreProvider.setSupervisedUid(userModel);
        //
       // subscribeUserToTopic();
        UserModel? sup = await _mainCoreProvider.getUserData();
        // si el supervisado tiene un supervisado mala cosa
        log ('**** signSupervisedIn UID ${sup?.uidSupervised} y ROL ${sup?.rol}'
            'e emailSup ${sup?.emailSup}');
        if(sup?.rol == 'supervisor'){
          NavigationService.pushReplacementAll(
            NavigationService.context,
            isNamed: true,
            page: RoutePaths.deleteSup,
            arguments: {'offAll': true},
          );
        }else{
          GetStorage().write('emailSup',emailSupervised);
          GetStorage().write('passwSup',passwordSupervised);
          NavigationService.pushReplacementAll(
            NavigationService.context,
            isNamed: true,
            page: RoutePaths.coreSplash,
            arguments: {'offAll': true},
          );
        }

        //navigationToHomeScreen(context);
        //await submitLogin(context, userModel);
      },
    );
  }

  createUserWithEmailAndPassword(
      BuildContext context, {
        required String email,
        required String password,
        required String name,
        required String rol
      }) async {
    state = const AuthState.loading();
    NavigationService.removeAllFocus(context);
    //no tiene sentido registrar a un supervisor sin verificar el email
      final result = await _authRepo.createUserWithEmailAndPassword(context,
          email: email, password: password, name: name, rol: rol);
      await result.fold(
        (failure) {
          state = AuthState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
        },
        (user) async {
          UserModel userModel = user;
          GetStorage().write('uidUsuario', user.uId);
          GetStorage().write('email', email);
          GetStorage().write('passw', password);
          GetStorage().write('rol', rol);
          AuthState.loading();
          await submitRegister(context, userModel);
        },

      );
  }
//TODO: save passw nuevo,, pero ya lo guardo en login ??
  sendPasswordResetEmail(
      BuildContext context, {
        required String email,
      }) async {
    state = const AuthState.loading();
    NavigationService.removeAllFocus(context);
    final result = await _authRepo.sendPasswordResetEmail(
      context,
      email: email,
    );
    result.fold(
          (failure) {
        state = AuthState.error(errorText: failure.message);
        AppDialogs.showErrorDialog(context, message: failure.message);
        },
        (done){
          AppDialogs.showErrorDialog(context, message: tr(context).reset);
          navigationToLogin(context);
        }

    );

  }

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
              navigationToCheckScreen(context);
        }
    );
  }

  /*openCollection(UserModel userModel) async {
    await _mainCoreProvider.openCollection(userModel);
  }*/

  Future submitRegister(BuildContext context, UserModel userModel) async {

    final result = await _mainCoreProvider.setUserToFirebase(userModel);
    await result.fold(
          (failure) {
        state = AuthState.error(errorText: failure.message);
        AppDialogs.showErrorDialog(context, message: failure.message);
      },
        (isSet) async {
          //openCollection(userModel);
          //subscribeUserToTopic();
          //que solo se lo pida al supervisor
          if((userModel.rol == 'supervisor')) {
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
/*
  subscribeUserToTopic() {
    FirebaseMessagingService.instance.subscribeToTopic(
      topic: 'general',
    );
  }*/

  navigationToHomeScreen(BuildContext context) {
    NavigationService.pushReplacement(
      context,
      isNamed: true,
      page: RoutePaths.home,
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
  }
}

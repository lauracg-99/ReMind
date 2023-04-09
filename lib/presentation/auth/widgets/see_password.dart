//Create a Provider
import 'package:hooks_riverpod/hooks_riverpod.dart';

final seePasswordProvider = StateNotifierProvider.autoDispose<SeePassword, bool>((ref) {
  return SeePassword(ref);
});

class SeePassword extends StateNotifier<bool> {
  final Ref ref;
  SeePassword(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}

final seePasswordProvider2 = StateNotifierProvider.autoDispose<SeePassword2, bool>((ref) {
  return SeePassword2(ref);
});

class SeePassword2 extends StateNotifier<bool> {
  final Ref ref;
  SeePassword2(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}

final seePasswordLoginProvider = StateNotifierProvider.autoDispose<SeePasswordLogin, bool>((ref) {
  return SeePasswordLogin(ref);
});

class SeePasswordLogin extends StateNotifier<bool> {
  final Ref ref;
  SeePasswordLogin(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}
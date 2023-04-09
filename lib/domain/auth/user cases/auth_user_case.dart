import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/auth/repo/auth_repo.dart';

class AuthUseCase {
  final AuthRepository _authRepository;

  AuthUseCase(this._authRepository);

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }
}

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import '../../../data/auth/models/user_model.dart';
import '../../../data/error/failures.dart';
import '../../../data/firebase/repo/firebase_caller.dart';
import '../../../data/firebase/repo/firestore_paths.dart';
import '../../../data/firebase/repo/i_firebase_caller.dart';

final userRepoProvider = Provider<UserRepo>((ref) => UserRepo(ref));

class UserRepo {
  UserRepo(this.ref) {
    _firebaseCaller = ref.watch(firebaseCaller);
  }


  final Ref ref;
  late IFirebaseCaller _firebaseCaller;
  UserModel? userModel;
  var user = FirebaseAuth.instance.currentUser?.uid;

  Future<Either<Failure, UserModel?>> getUserData(String userId) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.userDocument(userId),
      builder: (data, docId) {
        if (data is! ServerFailure) {
          userModel = data != null ? UserModel.fromMap(data, docId!) : null;
          /* uid = userModel?.uId;
          uidSuper = userModel?.uidSupervised;*/
          //addStringToSFRol(userModel?.rol);
          GetStorage().write('rol', userModel?.rol);
          GetStorage().write('uidUsuario', userModel?.uId);
          GetStorage().write('uidSup', userModel?.uidSupervised);
          //Other way to 'extract' the data
          return Right(userModel);
        } else {
          return Left(data);
        }
      },
    );
  }

  deleteSupUid(String uid) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userUId(uid),
      data: {
        "uidSupervised": ''
      },
      merge: true,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          //userModel = userModel!.copyWith(uidSupervised: user.uidSupervised);
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  deleteUidBD(String uid) async {
    return await _firebaseCaller.deleteData(
      path: FirestorePaths.userUId(uid),
    );
  }

  // guardamos los datos del usuario en firebase
  Future<Either<Failure, bool>> setUserData(UserModel userData) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userDocument(userData.uId),
      data: userData.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          userModel = userData;
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  setSupervisedUid(UserModel user) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userUId(user.uId),
      data: {
        "rol": 'supervisor',
        "uidSupervised": user.uidSupervised,
        "emailSup" : user.emailSup
      },
      merge: true,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          userModel = userModel!.copyWith(uidSupervised: user.uidSupervised);
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  registerUserData(UserModel userData) async {
    await _firebaseCaller.addDataToCollection(
      path: FirestorePaths.userDocument(userData.uId),
      data: userData.toMap(),
    );
  }

  Future clearUserLocalData() async {
    //uid = null;
    //userModel = null;
    GetStorage().write('uidUsuario', '');
    GetStorage().write('email', '');
    GetStorage().write('passw', '');
    GetStorage().write('rol', '');
    GetStorage().erase();
  }

  Future<String?> getUidSup() async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.userDocument(user!),
      builder: (data, docId) {
        userModel = data != null ? UserModel.fromMap(data, docId!) : null;
        /*uid = userModel?.uId;
          uidSuper = userModel?.uidSupervised;*/
        //Other way to 'extract' the data
        return userModel?.uidSupervised;
      },
    );
  }

  Future<Either<Failure, bool>> updateUserData(UserModel userData) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userDocument(GetStorage().read('uidUsuario')),
      data: userData.toMap(),
      merge: true,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          userModel = userData;
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> updateUserImage(File? imageFile) async {
    Either<Failure, String> result = await _firebaseCaller.uploadImage(
      path: FirestorePaths.profilesImagesPath(GetStorage().read('uidUsuario')),
      file: imageFile!,
      builder: (data) {
        if (data is! ServerFailure) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
    return result.fold(
          (failure) {
        return Left(failure);
      },
          (imageUrl) async {
        return await setUserImage(imageUrl);
      },
    );
  }

  Future<Either<Failure, bool>> setUserImage(String imageUrl) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userDocument(GetStorage().read('uidUsuario')),
      data: {"image": imageUrl},
      merge: true,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          userModel = userModel!.copyWith(image: imageUrl);
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

}
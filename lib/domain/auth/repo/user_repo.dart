import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/dependencies.dart';
import 'package:remind/common/storage_keys.dart';
import 'package:remind/presentation/tasks/providers/name_task_provider.dart';
import 'dart:io';
import '../../../data/auth/manage_supervised/solicitud.dart';
import '../../../data/auth/models/supervised.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../data/error/failures.dart';
import '../../../data/firebase/repo/firebase_caller.dart';
import '../../../data/firebase/repo/firestore_paths.dart';
import '../../../data/firebase/repo/i_firebase_caller.dart';
import '../../../presentation/profile/components/name_supervised_component.dart';
import '../../../presentation/utils/dialogs.dart';

final userRepoProvider = Provider<UserRepo>((ref) => UserRepo(ref));

class UserRepo {
  UserRepo(this.ref) {
    _firebaseCaller = ref.watch(firebaseCaller);
  }


  final Ref ref;
  late IFirebaseCaller _firebaseCaller;
  UserModel? userModel;
  var user = FirebaseAuth.instance.currentUser?.uid;
  Dependencies dependencies = Dependencies();

  Future<Either<Failure, UserModel?>> getUserData(String userId) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.userDocument(userId),
      builder: (data, docId) {
        if (data is! ServerFailure) {
          userModel = data != null ? UserModel.fromMap(data, docId!) : null;
          dependencies.write(StorageKeys.rol, userModel?.rol);
          dependencies.write(StorageKeys.uidUsuario, userModel?.uId);
          dependencies.write(StorageKeys.email, userModel?.email);
          dependencies.write(StorageKeys.name, userModel?.email);

          if(userModel?.rol == StorageKeys.SUPERVISOR){
            //dependencies.writeListUsers(StorageKeys.supervisados, userModel?.supervisados);
            var lista = userModel?.supervisados?.isNotEmpty;
            if(userModel?.lastEmailSup == '' && lista!){
              dependencies.write(StorageKeys.lastEmailSup, userModel?.supervisados?.first.uId);
              dependencies.write(StorageKeys.lastUIDSup, userModel?.supervisados?.first.email);
            } else {
              dependencies.write(StorageKeys.lastEmailSup, userModel?.lastEmailSup);
              dependencies.write(StorageKeys.lastUIDSup, userModel?.lastUIDSup);
            }
          }

          //Other way to 'extract' the data
          return Right(userModel);
        } else {
          return Left(data);
        }
      },
    );
  }


  Future<UserModel> getDatosSup(String userId) async {
    log('*** user_repo getDatosSup $userId');
    return await _firebaseCaller.getData(
      path: FirestorePaths.userDocument(userId),
      builder: (data, id) {
        return UserModel.fromMap(data, id!);
      },
    );
  }

  Future<UserModel> getDatosUsuario(String userId) async {
    log('*** user_repo get DAtos usuario $userId');
    return await _firebaseCaller.getData(
      path: FirestorePaths.userDocument(userId),
      builder: (data, id) {
        userModel = UserModel.fromMap(data, id!);
        return userModel!;
      },
    );
  }

  Future<Either<Failure, bool>> addNewSupervisedByUID(String uid) async {
    //obtenemos los datos del supervisado
    UserModel usuario = await getDatosUsuario(
        GetStorage().read(StorageKeys.uidUsuario)
    );
    UserModel? dataUser = await getDatosSup(uid);

    List<Supervised>? list = usuario.supervisados ?? []; // Initialize with an empty list if null

    var newSupUser = Supervised.fromUserModel(dataUser, (usuario.lastUIDSup == '') ? 'true' : 'false');

    log(newSupUser.toString());

    list.add(
        Supervised.fromUserModel(dataUser, (usuario.lastUIDSup == '') ? 'true' : 'false')
    );

    var newUId = '';
    var newEmail = '';

    if(usuario.lastUIDSup == ''){
      newUId = newSupUser.uId;
      newEmail = newSupUser.email;
      dependencies.write(StorageKeys.lastUIDSup, newUId);
      dependencies.write(StorageKeys.lastEmailSup, newEmail);
      ref.watch(nameSupervisedProvider.notifier).changeState(change:
      newSupUser.name ?? newEmail);
    } else {
      newUId = usuario.lastUIDSup ?? '';
      newEmail = usuario.lastEmailSup ?? '';
    }


    log('** list ${list.first.email}');

    //dependencies.writeListUsers(StorageKeys.supervisados, list);

    // Convierte la lista de objetos Supervised a una lista de mapas
    List<Map<String, dynamic>> supervisedListMap =
    list.map((supervised) => supervised.toMap()).toList();

    return await _firebaseCaller.updateData(
      path: FirestorePaths.userUId(
          GetStorage().read(StorageKeys.uidUsuario)
      ),
      data: {
        'supervisados': FieldValue.arrayUnion(supervisedListMap),
        'lastUIDSup' : newUId,
        'lastEmailSup': newEmail
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          log('right');
          return Right(data);
        } else {
          log('left');
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> updateSupervisedByUID(String uid, Supervised newUser) async {
    List<Supervised>? list = userModel?.supervisados ?? [];
    if(list != null) {
      if(list.isNotEmpty) {
        list.forEach((supervisado) {
          if (supervisado.uId == uid) {
            list.remove(supervisado);
          }
        });
      }
    }


    // Convierte la lista de objetos Supervised a una lista de mapas
    List<Map<String, dynamic>> supervisedListMap =
    list.map((supervised) => supervised.toMap()).toList();

    //dependencies.writeListUsers(StorageKeys.supervisados, list);

    return await _firebaseCaller.updateData(
      path: FirestorePaths.userUId(GetStorage().read(StorageKeys.uidUsuario)),
      data: {
        'supervisados': FieldValue.arrayUnion(supervisedListMap),
      },
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

  Future<Either<Failure, bool>> updateSelectUserUIDLast() async {

    return await _firebaseCaller.updateData(
      path: FirestorePaths.userUId(GetStorage().read(StorageKeys.uidUsuario)),
      data: {
        'lastUIDSup': '',
        'lastEmailSup': '',
      },
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

  Future<Either<Failure, bool>> selectedSupervisedByUID(Supervised selectSupervised, String selected) async {

    final updatedSupervisados = userModel?.supervisados?.map((supervised) {
      if (supervised.uId == selectSupervised.uId) {
        return Supervised(
            uId: supervised.uId,
            name: supervised.name,
            email: supervised.email,
            image: supervised.image,
            rol: supervised.rol,
            selected: 'true'
        );
      }else {
        return Supervised(
            uId: supervised.uId,
            name: supervised.name,
            email: supervised.email,
            image: supervised.image,
            rol: supervised.rol,
            selected: 'false'
        );
      }
    }).toList();


    List<Map<String, dynamic>> supervisedListMap = (updatedSupervisados != null)
    ? updatedSupervisados.map((supervised) => supervised.toMap()).toList()
    : [];


    return await _firebaseCaller.updateData(
      path: FirestorePaths.userUId(GetStorage().read(StorageKeys.uidUsuario)),
      data: {
        'lastUIDSup': selectSupervised.uId,
        'lastEmailSup': selectSupervised.email,
        'supervisados': supervisedListMap,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          GetStorage().write(StorageKeys.lastUIDSup, selectSupervised.uId);
          GetStorage().write(StorageKeys.lastEmailSup, selectSupervised.email);
          GetStorage().write(StorageKeys.lastNameSup, selectSupervised.name);
          ref.watch(nameSupervisedProvider.notifier).changeState(change: selectSupervised.name ?? selectSupervised.email);
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }


  Future<Either<Failure, bool>> deleteSupervisedByUID(String uid) async {
    log('uid sup $uid');
    List<Supervised>? list = userModel?.supervisados ?? [];
    List<Supervised>? manageList = list;

    if (manageList.isNotEmpty) {
      manageList.removeWhere((supervisado) => supervisado.uId == uid);
    }

    list = manageList;
    List<Map<String, dynamic>> supervisedListMap =
        list.map((supervised) => supervised.toMap()).toList();

    log('supervisedListMap ${supervisedListMap.toString()} ${GetStorage().read(StorageKeys.uidUsuario)}');
    log('path: ${FirestorePaths.userUId(GetStorage().read(StorageKeys.uidUsuario))}');


    return await _firebaseCaller.updateData(
      path: FirestorePaths.userUId(GetStorage().read(StorageKeys.uidUsuario)),
      data: {
        'supervisados': supervisedListMap
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }


  Future<Either<Failure, bool>> deleteSupervisedAll(String uid) async {
    List<Supervised>? list = userModel?.supervisados ?? [];

    list = [];


    // Convierte la lista de objetos Supervised a una lista de mapas
    List<Map<String, dynamic>> supervisedListMap =
    list.map((supervised) => supervised.toMap()).toList();


    dependencies.write(StorageKeys.lastEmailSup, '');
    dependencies.write(StorageKeys.lastUIDSup, '');
    dependencies.write(StorageKeys.lastNameSup, '');
    //dependencies.writeListUsers(StorageKeys.supervisados, []);

    return await _firebaseCaller.updateData(
      path: FirestorePaths.userUId(uid),
      data: {
        'supervisados': FieldValue.arrayUnion(supervisedListMap),
        'lastUIDSup': '',
        'lastEmailSup': ''
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
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

  Future<Either<Failure, bool>> setUserData(UserModel userData) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userDocument(userData.uId),
      data: userData.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          userModel = userData;
          openPetitionDB(userModel!.uId);
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }



  Future<void> openPetitionDB(String uid) async {
    Solicitud solicitud = Solicitud(id: '', uidBoss: '', emailBoss: '',
        emailSup: '', estado: '', uidSup: '', fotoSup: '');

    solicitud.id = await _firebaseCaller.addDataToCollection(
        path: FirestorePaths.userPetitionCollection(uid),
        data: solicitud.toMap()
    );
    await _firebaseCaller.setData(
      path: FirestorePaths.userPetition(uid, solicitud.id!),
      data: solicitud.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
    log('uid ${uid} solicitud.id ${solicitud.id}');
    //borramos solicitud de prueba
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.userPetitionById(uid, solicitud.id!)
    );

  }

  Future<Either<Failure, bool>> setPetition(Solicitud solicitud) async {
    log('*** UID SUb ${solicitud.uidSup}');
    // Comprobar si ya existe una entrada con los mismos datos
    final existingPetition = await _firebaseCaller.getCollectionData(
      path: FirestorePaths.userPetitionCollection(solicitud.uidBoss),
      builder: (data) {
        // Verificar si se encontraron documentos que coinciden con los criterios de búsqueda
        if (data != null && data.isNotEmpty) {
          return Future.value(Right(true)); // Ya existe una entrada con los mismos datos
        } else {

          return Future.value(Right(false)); // No existe una entrada con los mismos datos
        }
      },
      queryBuilder: (query) {
        // Construir la consulta con los criterios de búsqueda
        return query
            .where('emailSup', isEqualTo: solicitud.emailSup)
            .where('uidSup', isEqualTo: solicitud.uidSup)
            .limit(1); // Limitar la consulta a un solo resultado
      },
    );

    if (existingPetition is Right && existingPetition.value == true) {
      return Left(ServerFailure(message: 'error'));;
    } else{
      log('setPetition ${solicitud.uidBoss}');
      //uid del supervisor
      solicitud.id = await _firebaseCaller.addDataToCollection(
          path: FirestorePaths.userPetitionCollection(solicitud.uidBoss),
          data: solicitud.toMap()
      );
      //añadimos la solicitud
      await _firebaseCaller.setData(
        path: FirestorePaths.userPetition(solicitud.uidBoss,  solicitud.id!),
        data: solicitud.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            //userModel = userData;
            return Right(data);
          } else {
            return Left(data);
          }
        },
      );

      return await setPetitionTOSup(solicitud);
    }

  }

  Future<Either<Failure, bool>> setPetitionTOSup(Solicitud solicitud) async {
    //añadimos la solicitud en el supervisado
    log('setPetitionTOSup ${solicitud.id} ${solicitud.uidSup} ${solicitud.uidBoss}');
    return await _firebaseCaller.setData(
      path: FirestorePaths.userPetition(solicitud.uidSup, solicitud.id!),
      data: solicitud.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          //userModel = userData;
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> updatePetition(Solicitud solicitud) async {
    //updateamos el estado en los dos lados
    //con el uid del supervisor en la solicitud al supervisado
    await _firebaseCaller.updateData(
      path: FirestorePaths.userPetition(solicitud.uidBoss,  solicitud.id!),
      data: solicitud.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          //userModel = userData;
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
    return await _firebaseCaller.updateData(
      path: FirestorePaths.userPetition(solicitud.uidSup, solicitud.id!),
      data: solicitud.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          //userModel = userData;
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );

  }

  Future<void> deletePetition(Solicitud solicitud) async {
    //updateamos el estado en los dos lados
    //con el uid del supervisor en la solicitud al supervisado
    await _firebaseCaller.deleteData(
      path: FirestorePaths.userPetition(solicitud.uidBoss,  solicitud.id!),
    );

    await _firebaseCaller.deleteData(
      path: FirestorePaths.userPetition(solicitud.uidSup,  solicitud.id!),
    );
  }

  registerUserData(UserModel userData) async {
    await _firebaseCaller.addDataToCollection(
      path: FirestorePaths.userDocument(userData.uId),
      data: userData.toMap(),
    );
  }

  Future clearUserLocalData() async {
    GetStorage().write(StorageKeys.uidUsuario, '');
    GetStorage().write(StorageKeys.email, '');
    GetStorage().write(StorageKeys.passw, '');
    GetStorage().write(StorageKeys.rol, '');
    GetStorage().write(StorageKeys.lastUIDSup, '');
    GetStorage().write(StorageKeys.lastEmailSup, '');
    //GetStorage().write(StorageKeys.supervisados, '');
    GetStorage().write(StorageKeys.SUPERVISOR, '');
    GetStorage().write(StorageKeys.name, '');
    GetStorage().write(StorageKeys.lastNameSup, '');

    GetStorage().erase();
  }

  Future<Either<Failure, bool>> updateUserData(UserModel userData) async {
    return await _firebaseCaller.setData(
      path: FirestorePaths.userDocument(GetStorage().read(StorageKeys.uidUsuario)),
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
      path: FirestorePaths.profilesImagesPath(GetStorage().read(StorageKeys.uidUsuario)),
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
      path: FirestorePaths.userDocument(GetStorage().read(StorageKeys.uidUsuario)),
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
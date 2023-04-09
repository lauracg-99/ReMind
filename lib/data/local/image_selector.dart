import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


import '../error/exceptions.dart';
import '../error/failures.dart';
import '../../presentation/styles/sizes.dart';

class ImageSelector {
  ImageSelector._();

  static final instance = ImageSelector._();

  static String? _appDocDirPath;

  Future<String> get appDocDir async {
    if (_appDocDirPath != null) return _appDocDirPath!;
    _appDocDirPath = await getAppDocDir();
    return _appDocDirPath!;
  }

  getAppDocDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  Future<Either<Failure, File?>> pickImage(
      BuildContext context, {
        required bool fromCamera,
      }) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxHeight: Sizes.pickedImageMaxSize(context),
        maxWidth: Sizes.pickedImageMaxSize(context),
      );
      return pickedFile != null
          ? Right(File(pickedFile.path))
          : const Right(null);
    } catch (e) {
      log(e.toString());
      final failure = DefaultFailure(message: Exceptions.errorMessage(e));
      return Left(failure);
    }
  }
}

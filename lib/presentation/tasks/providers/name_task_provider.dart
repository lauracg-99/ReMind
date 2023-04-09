//Create a Provider
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final nameTaskProvider = StateNotifierProvider.autoDispose<NameTaskProvider, String>((ref) {
  return NameTaskProvider(ref);
});

class NameTaskProvider extends StateNotifier<String> {
  final Ref ref;

  static String nameTask = '';
  TextEditingController nameController = TextEditingController();

  NameTaskProvider(this.ref) : super('');

  setNameTask(String name ){
    nameTask= name;
  }

  controllerName(TextEditingController nameController){
    nameTask = nameController.text;
  }

  getNameTask(){
    return nameTask;
  }

  clean(){
    nameTask = '';
  }


}
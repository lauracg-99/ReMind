import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/storage_keys.dart';
import '../../../data/auth/models/supervised.dart';

final selectSupervisedProvider = StateNotifierProvider.autoDispose<SelectSupervised, bool>((ref) {
  return SelectSupervised(ref);
});

class SelectSupervised extends StateNotifier<bool> {
  final Ref ref;
  SelectSupervised(this.ref) : super(true);

  changeState({required bool change, required String uid}) {
    if(uid == GetStorage().read(StorageKeys.lastUIDSup)){
      state = true;
    } else {
      state = false;
    }

  }

}
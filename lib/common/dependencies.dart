import 'package:get_storage/get_storage.dart';

class Dependencies {
  static final storage = GetStorage();

  static Future<void> init() async {
    await GetStorage.init();
  }

  Future<void> restore() async {
    await GetStorage().erase();
  }

  String read(String key) {
    return GetStorage().read(key);
  }

   Future<void> write(String key, String? value) async {
     await GetStorage().write(key, value);
  }
}

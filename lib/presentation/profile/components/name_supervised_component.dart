import 'package:hooks_riverpod/hooks_riverpod.dart';

final nameSupervisedProvider = StateNotifierProvider<NameSupervised, String>((ref) {
  return NameSupervised(ref);
});

class NameSupervised extends StateNotifier<String> {
  final Ref ref;
  NameSupervised(this.ref) : super('');

  changeState({required String change}) {
    state = change;
  }

}
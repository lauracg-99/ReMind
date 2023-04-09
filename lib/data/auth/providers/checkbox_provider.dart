import 'package:hooks_riverpod/hooks_riverpod.dart';

final checkBoxProvider = StateNotifierProvider<CustomCheckBox, bool>((ref) {
  return CustomCheckBox(ref);
});

class CustomCheckBox extends StateNotifier<bool> {
  final Ref ref;
  CustomCheckBox(this.ref) : super(false);

  changeState({required bool change}) {
    state = change;
  }

}
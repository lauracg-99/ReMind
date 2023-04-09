import 'package:flutter_riverpod/flutter_riverpod.dart';


//Create a Provider
final switchRangeProvider = StateNotifierProvider.autoDispose<SwitchRangeButton, bool>((ref) {
  return SwitchRangeButton(ref);
});

class SwitchRangeButton extends StateNotifier<bool> {
  final Ref ref;
  SwitchRangeButton(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}
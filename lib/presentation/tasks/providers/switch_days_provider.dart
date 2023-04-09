import 'package:flutter_riverpod/flutter_riverpod.dart';


//Create a Provider
final switchDaysProvider = StateNotifierProvider.autoDispose<SwitchDaysButton, bool>((ref) {
  return SwitchDaysButton(ref);
});

class SwitchDaysButton extends StateNotifier<bool> {
  final Ref ref;
  SwitchDaysButton(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}
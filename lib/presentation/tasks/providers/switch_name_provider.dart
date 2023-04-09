import 'package:flutter_riverpod/flutter_riverpod.dart';


//Create a Provider
final switchNameProvider = StateNotifierProvider.autoDispose<SwitchNameButton, bool>((ref) {
  return SwitchNameButton(ref);
});

class SwitchNameButton extends StateNotifier<bool> {
  final Ref ref;
  SwitchNameButton(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }


}

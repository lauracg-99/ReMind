import 'package:flutter_riverpod/flutter_riverpod.dart';


//Create a Provider
final switchRepProvider = StateNotifierProvider.autoDispose<SwitchRepButton, bool>((ref) {
  return SwitchRepButton(ref);
});

class SwitchRepButton extends StateNotifier<bool> {
  final Ref ref;
  SwitchRepButton(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}
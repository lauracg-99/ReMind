import 'package:flutter_riverpod/flutter_riverpod.dart';


//Create a Provider
final switchButtonProvider = StateNotifierProvider.autoDispose<SwitchButton, bool>((ref) {
  return SwitchButton(ref);
});

final switchButtonProviderAdd = StateNotifierProvider<SwitchButton, bool>((ref) {
  return SwitchButton(ref);
});

class SwitchButton extends StateNotifier<bool> {
  final Ref ref;
  SwitchButton(this.ref) : super(true);

  changeState({required bool change}) {
    state = change;
  }

}


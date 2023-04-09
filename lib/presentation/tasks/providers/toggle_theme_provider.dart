import 'package:flutter_riverpod/flutter_riverpod.dart';


//Create a Provider
final toggleButtonProvider = StateNotifierProvider.autoDispose<ToggleButton, int>((ref) {
  return ToggleButton(ref);
});

final toggleButtonProviderAdd = StateNotifierProvider<ToggleButton, int>((ref) {
  return ToggleButton(ref);
});

class ToggleButton extends StateNotifier<int> {
  final Ref ref;
  ToggleButton(this.ref) : super(0);

  changeState({required int change}) {
    state = change;
  }

}


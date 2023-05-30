import 'package:hooks_riverpod/hooks_riverpod.dart';

final numSolicitudesProvider = StateNotifierProvider<NumSolicitudes, int>((ref) {
  return NumSolicitudes(ref);
});

class NumSolicitudes extends StateNotifier<int> {
  final Ref ref;
  NumSolicitudes(this.ref) : super(0);

  changeState({required int change}) {
    state = change;
  }

}
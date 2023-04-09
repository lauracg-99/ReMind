import 'package:freezed_annotation/freezed_annotation.dart';
part 'tarea_state.freezed.dart';
@Freezed()
class TareaState with _$TareaState {
  const factory TareaState.loading() = _Loading;

  const factory TareaState.error({String? errorText}) = _Error;

  const factory TareaState.available() = _Available;
}

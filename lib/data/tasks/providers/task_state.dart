import 'package:freezed_annotation/freezed_annotation.dart';
part 'task_state.freezed.dart';
@Freezed()
class TaskState with _$TaskState {
  const factory TaskState.loading() = _Loading;

  const factory TaskState.error({String? errorText}) = _Error;

  const factory TaskState.available() = _Available;
}

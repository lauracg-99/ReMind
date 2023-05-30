import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/tasks/models/task_model.dart';
import '../../../data/tasks/providers/task_provider.dart';


final getTasks = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(tasksRepoProvider).getTasksStream();
});

final getTasksDone = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(tasksRepoProvider).getTasksDoneStream();
});

final getTasksSup = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(tasksRepoProvider).getTasksStreamSup();
});

final getTasksSupDone = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(tasksRepoProvider).getTasksDoneStreamSup();
});


final taskMultipleToDoStreamProviderNOTDONE = StreamProvider<List<List<TaskModel>>>((ref) {
  return CombineLatestStream.list([
    ref.watch(tasksRepoProvider).getTasksStream(),
    ref.watch(tasksRepoProvider).getTasksBossS()
  ]);
});

final taskMultipleAll = StreamProvider<List<List<TaskModel>>>((ref) {
  return CombineLatestStream.list([
    ref.watch(tasksRepoProvider).getTasksStream(),
    ref.watch(tasksRepoProvider).getTasksBossS(),
    ref.watch(tasksRepoProvider).getTasksDoneStream(),
    ref.watch(tasksRepoProvider).getTasksDoneStreamBossS()
  ]);
});

final taskMultipleToDoStreamProviderDONE = StreamProvider<List<List<TaskModel>>>((ref) {
  return CombineLatestStream.list([
    ref.watch(tasksRepoProvider).getTasksDoneStream(),
    ref.watch(tasksRepoProvider).getTasksDoneStreamBossS()
  ]);
});

final taskMultipleToDoStreamProviderBoss = StreamProvider<List<List<TaskModel>>>((ref) {
  return CombineLatestStream.list([
    ref.watch(tasksRepoProvider).getTasksBossStream(),
    ]);
});



final taskMultipleToDoCompleteStreamProviderBoss = StreamProvider<List<List<TaskModel>>>((ref) {
  return CombineLatestStream.list([
    ref.watch(tasksRepoProvider).getTasksDoneStreamBoss(),
  ]);
});


import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/tasks/providers/task_state.dart';

import '../../../presentation/utils/dialogs.dart';
import '../../error/failures.dart';
import '../models/task_model.dart';
import '../repo/task_repo.dart';

final tasksRepoProvider = Provider<TasksRepo>((ref) => TasksRepo(ref));

final taskProvider =
StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref);
});

class TaskNotifier extends StateNotifier<TaskState> {

  TaskNotifier(this.ref) : super(const TaskState.available()) {
    _tasksRepo = ref.watch(tasksRepoProvider);
  }

  final Ref ref;
  late TasksRepo _tasksRepo;

  Stream<List<TaskModel>> getTasksStream() {
    return _tasksRepo.getTasksStream();
  }

  Stream<List<TaskModel>> getTasksStreamBoss() {
    return _tasksRepo.getTasksBossS();
  }

  Stream<List<TaskModel>> getTasksStreamDone() {
    return _tasksRepo.getTasksDoneStream();
  }

  Stream<List<TaskModel>> getTasksStreamBossDone() {
    return _tasksRepo.getTasksDoneStreamBoss();
  }

  Future<Either<Failure?, TaskModel>> getTaskById(BuildContext context,
      {required String taskId,}) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.getTaskByName(taskId: taskId);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure?.message);
          AppDialogs.showErrorDialog(context, message: failure?.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

  Future<Either<Failure?, TaskModel>> getTaskByBossId(BuildContext context,
      {required String taskId,}) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.getTaskBossByName(taskId: taskId);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure?.message);
          AppDialogs.showErrorDialog(context, message: failure?.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }


  Future<Either<Failure, bool>> addTask(TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.addTask(taskModel);
    return await result.fold(
          (failure) {
            state = TaskState.error(errorText: failure.message);
            return Left(failure);
          },
          (task) async {
            state = const TaskState.available();
            return Right(task);
          }
    );
  }

  Future<void> deleteTask(BuildContext context, TaskModel taskModel) async {
    await _tasksRepo.deleteTask(taskModel);
  }

  Future<Either<Failure, bool>> resetTask(BuildContext? context, TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.resetTasks(taskModel: taskModel);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure.message);
          if(context != null) {
            AppDialogs.showErrorDialog(context, message: failure.message);
          }
      return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

  Future<Either<Failure, bool>> checkTask(BuildContext context,
      TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.checkTask(taskModel: taskModel);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

  Future<Either<Failure, bool>> unCheckTask(BuildContext context,
      TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.unCheckTask(taskModel: taskModel);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

  Future<Either<Failure, bool>> checkTaskBoss(BuildContext context,
      TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.checkTaskBoss(taskModel: taskModel);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

  Future<Either<Failure, bool>> unCheckTaskBoss(BuildContext context,
      TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.unCheckTaskBoss(taskModel: taskModel);
    return await result.fold(
            (failure) {
              state = TaskState.error(errorText: failure.message);
              AppDialogs.showErrorDialog(context, message: failure.message);
              return Left(failure);
            },
            (task) async {
              state = const TaskState.available();
              return Right(task);
            }
    );
  }

  Future<Either<Failure, bool>> updateTask(BuildContext context,
      TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.updateTask(taskModel);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

  Future<Either<Failure, bool>> updateTaskBoss(BuildContext context,
      TaskModel taskModel) async {
    state = const TaskState.loading();
    final result = await _tasksRepo.updateTaskBoss(taskModel);
    return await result.fold(
            (failure) {
          state = TaskState.error(errorText: failure.message);
          AppDialogs.showErrorDialog(context, message: failure.message);
          return Left(failure);
        },
            (task) async {
          state = const TaskState.available();
          return Right(task);
        }
    );
  }

}
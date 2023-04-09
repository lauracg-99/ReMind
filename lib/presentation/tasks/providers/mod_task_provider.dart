import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/tasks/models/task_model.dart';
import '../../../data/tasks/providers/task_provider.dart';
import '../../../data/tasks/repo/task_repo.dart';

final selectedTaskProvider = StateProvider<TaskModel?>((ref) => null);

final modTaskProvider = Provider<ModTaskProvider>((ref) => ModTaskProvider(ref));


class ModTaskProvider {
  final Ref ref;

  ModTaskProvider(this.ref) {
  _selectTask = ref.watch(tasksRepoProvider);
  }

  late TasksRepo _selectTask;

  bool showName = false;
  bool showDays = false;
  bool showRange = false;
  bool showRep = false;

  setShowName(bool show){
    showName= show;
  }

  setShowDays(bool show){
    showDays= show;
  }

  setShowRange(bool show){
    showRange= show;
  }

  setShowRep(bool show){
    showRep= show;
  }


  modTask(TaskModel taskModel){
    _selectTask.updateTask(taskModel.toMap(), taskId: taskModel.taskId);
  }


}
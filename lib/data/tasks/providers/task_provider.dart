import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repo/task_repo.dart';

final tasksRepoProvider = Provider<TasksRepo>((ref) => TasksRepo(ref));

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/services/localization_service.dart';
import '../tasks/pages/boss/add_task_boss_screen.dart';
import '../tasks/pages/boss/completed_boss_tasks_screen.dart';
import '../tasks/pages/boss/show_supervisor_tasks.dart';
import '../tasks/pages/supervised/add_task_screen.dart';
import '../tasks/pages/supervised/completed_tasks_screen.dart';
import '../tasks/pages/supervised/show_tasks_screen.dart';

class Index extends StateNotifier<int> {
  Index() : super(1);
  set value(int index) => state = index;
}

final indexProvider = StateNotifierProvider((ref) => Index());

class HomeScreen extends ConsumerWidget {
   const HomeScreen({Key? key}) : super(key: key);
   static bool supervisor = false;

   setSupervisor(bool set){
     supervisor = set;
   }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController controller = PageController(initialPage: 1);
    final int menuIndex = ref.watch(indexProvider) as int;

    final String rol = GetStorage().read('rol') ?? '';
    setSupervisor(rol == 'supervisor');

    final List<Widget> pages = supervisor
        ? const [
      AddTaskScreenBoss(),
      ShowSupervisorTasks(),
      CompletedBossTasks(),
    ]
        : const [
      AddTaskScreen(),
      ShowTasks(),
      CompletedTasks(),
    ];

    return Scaffold(
      body: PageView(
          controller: controller,
          children: pages,
          onPageChanged: (i) => ref.read(indexProvider.notifier).value = i
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).iconTheme.color,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.add), label: tr(context).add_screen),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: tr(context).show_screen),
            BottomNavigationBarItem(icon: Icon(Icons.library_add_check_outlined),
                label: tr(context).show_done_screen),
          ],
          currentIndex: menuIndex,
          onTap: (i) {
            ref.read(indexProvider.notifier).value = i;
            controller.animateToPage(i,
                duration: const Duration(microseconds: 500), curve: Curves.easeInOut);
          }

          ),
    );
  }

}
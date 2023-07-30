//Create a Provider
import 'package:hooks_riverpod/hooks_riverpod.dart';

final selectFilterProvider = StateNotifierProvider<FilterChoice,int>((ref) {
  return FilterChoice();
});

class FilterChoice extends StateNotifier<int> {
  FilterChoice() : super(7);

  void setChoice(int selectChoice) {
    state = selectChoice;
  }

  void clean() {
    state = 7;
  }
}

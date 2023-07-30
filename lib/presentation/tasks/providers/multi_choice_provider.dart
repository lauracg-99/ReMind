//Create a Provider
import 'package:hooks_riverpod/hooks_riverpod.dart';

final selectDaysMultiChoice = StateNotifierProvider.autoDispose<MultiChoice,List<String>>((ref) {
  return MultiChoice(ref);
});

class MultiChoice extends StateNotifier<List<String>> {
  final Ref ref;
  List<String> tags = [];

  MultiChoice(this.ref) : super([]);

  //changeTheme({required bool change}) {state = change;}

  setChoice(List<String> selectedChoices){
    tags = selectedChoices;
  }

  void changeChoice({required List<String> val,required List<String> mix }){
    if (val.contains("Todos los días")) {
      if (val.last != "Todos los días") {
        val.remove("Todos los días");
      } else {
        val = ["Todos los días"];
      }
    } else {
      if(val.contains("Lunes") && val.contains("Martes") && val.contains("Miércoles")
          && val.contains("Jueves") && val.contains("Viernes")
          && val.contains("Sábado") &&  val.contains("Domingo")){
        val = ["Todos los días"];
      }
    }

    mix=val;
    tags = mix;
    state = mix;
  }

  void changeChoiceGal({required List<String> val,required List<String> mix }){
    if (val.contains("Todos os días")) {
      if (val.last != "Todos os días") {
        val.remove("Todos os días");
      } else {
        val = ["Todos os días"];
      }
    } else {
      if(val.contains("Luns") && val.contains("Martes") && val.contains("Mércores")
          && val.contains("Xoves") && val.contains("Venres")
          && val.contains("Sábado") &&  val.contains("Domingo")){
        val = ["Todos os días"];
      }
    }

    mix=val;
    tags = mix;
    state = mix;
  }

  clean(){
    tags.clear();
  }


}
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../notifications/utils/notifications.dart';
import 'package:http/http.dart' as http;

bool checkRange(String ini, String fin, String avisar){

  var splitIni = ini.split(':');
  //pasamos all a minutos
  int iniH = int.parse(splitIni[0])*60 + int.parse(splitIni[1]);

  var splitFin = fin.split(':');
  //pasamos all a minutos
  int finH = int.parse(splitFin[0])*60 + int.parse(splitFin[1]);

  if(finH - iniH  < int.parse(avisar)) {
    return false;
  }

  return true;
}

int getNumDay(String day){
  int num = 0;
  switch(day){
    case 'Lunes': num = 1; break;
    case 'Martes': num = 2; break;
    case 'Miércoles': num = 3; break;
    case 'Jueves': num = 4; break;
    case 'Viernes': num = 5; break;
    case 'Sábado': num = 6; break;
    case 'Domingo': num = 7; break;
  }

  return num;
}

String getStrDay(int day){
  String d = '';
  switch(day){
    case 1: d = 'Lunes'; break;
    case 2: d = 'Martes'; break;
    case 3: d = 'Miércoles'; break;
    case 4: d = 'Jueves'; break;
    case 5: d = 'Viernes'; break;
    case 6: d = 'Sábado'; break;
    case 7: d = 'Domingo'; break;
  }

  return d;

}

//hago esto para gestionar de forma más fácil la base de datos
List<String> saveDays(String days){
  if(days == '[Todos los días]'){
    days = '[Lunes, Martes, Miércoles, Jueves, Viernes, Sábado, Domingo]';
  }

  days = reformDays(days);

  var amountOfDays = days.split(' ');

  return amountOfDays;

  //return days;
}


String reformDays(String days){
  var left = days.replaceAll('[','');
  var right = left.replaceAll(']','');
  var center = right.replaceAll(',','');
  return center;

}



//calcular las horas a las que hay que avisar

List<String> notiHours(String ini, String fin, String avisar){
  var horas = [''];
  var splitIni = ini.split(':');
  //pasamos all a minutos
  int iniH = int.parse(splitIni[0])*60 + int.parse(splitIni[1]);

  var splitFin = fin.split(':');
  //pasamos all a minutos
  int finH = int.parse(splitFin[0])*60 + int.parse(splitFin[1]);

  for(int i = iniH; i <= finH ; i += int.parse(avisar) ){
    var duration = Duration(minutes:i);
    //log('HORAS.ADD ${duration.inHours}:${duration.inMinutes.remainder(60)}');
    // para evitar que guarde 8 en vez de 08

    if(duration.inMinutes.remainder(60)< 10){
      horas.add('${duration.inHours}:0${duration.inMinutes.remainder(60)}');
    }else{
      horas.add('${duration.inHours}:${duration.inMinutes.remainder(60)}');
    }

  }

  horas.removeWhere((item) => item == '');

  return horas;
}


String getTranslateDay(){
  var actualDay = DateTime.now().weekday;
  String day = '';
  switch(actualDay){
    case 1:
      day = 'Lunes';
      break;
    case 2:
      day = 'Martes';
      break;
    case 3:
      day ='Miércoles';
      break;
    case 4:
      day = 'Jueves';
      break;
    case 5:
      day = 'Viernes';
      break;
    case 6:
      day = 'Sábado';
      break;
    case 7:
      day = 'Domingo';
      break;
  }
  return day;
}

String tiempo(String hr){
  String t = "";
  //print(hr);

  if(hr != '00:00 - 00:00' && hr.isNotEmpty){
    int minutos = int.parse(hr);
    int hora = 0;
    if (minutos > 60) {

      hora = (minutos / 60).truncate();
      minutos = minutos - hora * 60;

      if(minutos != 0){
        t = 'Repetir cada ${hora} horas ${minutos} minutos';
      } else {
        if(hora == 1){
          t = 'Repetir cada ${hora} hora';
        } else {
          t = 'Repetir cada ${hora} horas';
        }
      }

    } else {
      t = 'Repetir cada ${minutos} minutos';
    }
  }
  return t;
}

List<String> ordenarDias(List<String> dias){
  return getDiasString(sortDay(dias));
}

List<dynamic> sortDay(List<String> selectedDia) {
  List<dynamic> numbers = [];

  for (var element in selectedDia) {
    numbers.add(mapDays[element]);
  }
  numbers.sort();
  return numbers;
}

Map<String, dynamic> mapDays = {
  "Lunes": 1,
  "Martes": 2,
  "Miércoles": 3,
  "Jueves": 4,
  "Viernes": 5,
  "Sábado": 6,
  "Domingo": 7,
  "Todos los días": 8
  //"Todos los días"
};

List<String> daysList = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
  'Todos los días'
];

List<String> getDiasString(List<dynamic> numeros) {
  List<String> tags = [];
  numeros.forEach((element) {
    //print(element.toString());
    if (element < 8) {
      //va de 0..7 no de 1..8
      tags.add(daysList.elementAt(element - 1));
    } else {
      tags.add("Todos los días"); //TODO: tr
    }
  });
  return tags;
}

// Función para convertir el formato de hora "HH:mm" a minutos desde la medianoche
int convertToMinutes(String time) {
  List<String> parts = time.split(":");
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  return hours * 60 + minutes;
}

List<TaskModel> sortTasksByBegin(List<TaskModel> tasks) {
  tasks.sort((a, b) {
    // Convierte las horas a minutos para compararlas
    int timeA = a.begin != null ? convertToMinutes(a.begin!) : 0;
    int timeB = b.begin != null ? convertToMinutes(b.begin!) : 0;
    return timeA.compareTo(timeB);
  });
  return tasks;
}

String getRepetitionText(int repetition, BuildContext context) {
  if (repetition >= 60) {
    int hours = repetition ~/ 60;
    int minutes = repetition % 60;
    if (minutes == 0) {
      return '${tr(context).repTime} $hours hora${hours > 1 ? 's' : ''}';
    } else {
      return '${tr(context).repTime} $hours hora${hours > 1 ? 's' : ''} ${tr(context).and} $minutes minuto${minutes > 1 ? 's' : ''}'; //TODO: tr
    }
  } else {
    return '${tr(context).repTime} $repetition minuto${repetition > 1 ? 's' : ''}';
  }
}

Future<String?> fetchRandomCatImage() async {
  final response = await http.get(Uri.parse('https://api.thecatapi.com/api/images/get?format=json&type=jpg'));
  if (response.statusCode == 200) {
    try {
      final jsonData = json.decode(response.body);
      if (jsonData is List && jsonData.isNotEmpty) {
        final imageUrl = jsonData[0]['url'].toString();
        return imageUrl;
      } else {
        return null;
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      return null;
    }
  } else {
    print('API request failed with status code: ${response.statusCode}');
    return null;
  }
}


/*// Función para obtener un ID de pokémon aleatorio
int getRandomPokemonId() {
  // Genera un ID de pokémon aleatorio entre 1 y 898 (número total de pokémon en la Pokédex hasta la fecha de corte de mi conocimiento en septiembre de 2021).
  return Random().nextInt(898) + 1;
}

// Función para obtener una URL de imagen de pokémon aleatorio
Future<String?> fetchRandomPokemonImage() async {
  final randomPokemonId = getRandomPokemonId();
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-form/$randomPokemonId/'));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return jsonData['sprites']['front_default'];
  } else {
    return null;
  }
}*/





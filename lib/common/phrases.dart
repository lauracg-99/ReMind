import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get_storage/get_storage.dart';

import '../domain/services/localization_service.dart';

class Phrases {

  List<String> frasesEs = [
    "¡Oye haz esto!",
    "Va tocando hacer esto:",
    "Que no se te olvide esto:",
    "${Emojis.music_trumpet}${Emojis.music_trumpet}${Emojis.music_trumpet}"
    "Es hora de hacer esto:",
    "Te recuerdo que tienes que hacer esto:",
    "Acuérdate que esto no se hace solo:",
    "Porfa esto:",
    "Parece que quedó buen día para hacer esto:",
    "Como alguien dijo alguna vez, es hora de:",

  ];

  List<String> frasesGl = [
    "Ei, fai isto!",
    "Toca facer isto:",
    "Que non se che esqueza isto:",
    "${Emojis.music_trumpet}${Emojis.music_trumpet}${Emojis.music_trumpet}",
    "É hora de facer isto:",
    "Lémbrache que tes que facer isto:",
    "Non te esquezas de que isto non se fai soa:",
    "Por favor, isto:",
    "Parece que quedou bo día para facer isto:",
    "Como alguén dixo algunha vez, é hora de:"
  ];

  String obtenerFraseAleatoria() {
    var idioma = GetStorage().read("idioma");
    var frases = (idioma == "GL") ? frasesGl : frasesEs;
    Random random = Random();
    int indiceAleatorio = random.nextInt(frases.length);
    return frases[indiceAleatorio];
  }
}
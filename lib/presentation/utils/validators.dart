import 'dart:developer';

import 'package:flutter/material.dart';

class Validators {
  Validators._();

  static final Validators instance = Validators._();


  String? Function(String?)? validateName(BuildContext context) {
    return (val){
      if(val!.isEmpty){
        return 'Inserte nombre';
      }else{
        return null;
      }
    };
  }

  String? Function(String?)? validateEmail(BuildContext context) {
    return (value) {
      if (value!.isEmpty) {
        return 'Introduce Email';
      } else if (!value.contains('@')) {
        return 'Por favor Introduce un email válido';
      }
      return null;
    };
  }

  String? Function(String?)? validateEmail2(BuildContext context, String value, String value2) {
    log('**** ${value} ${value2}');
    return (value) {
      if (value!.isEmpty) {
        return 'Introduce Email';
      } else if (!value.contains('@')) {
        return 'Por favor Introduce un email válido';
      }else {
        if(value != value2){
          return 'No coinciden los emails';
        }else {
          return null;
        }
      }
    };
  }

  String? Function(String?)? validateLoginPassword(BuildContext context) {
    return (value) {
      if (value!.isEmpty) {
        return 'Introduzca contraseña';
      } else if (value.length < 6) {
        return 'La contraseña tiene que ser mínimo de 6 caracteres!';
      } else {
        return null;
      }
    };
  }

  String? Function(String?)? validateRegisterPassword(BuildContext context) {
    return (value) {
      if (value!.isEmpty) {
        return 'Introduzca contraseña';
      } else if (value.length < 6) {
        return 'La contraseña tiene que ser mínimo de 6 caracteres!';
      } else {
        return null;
      }
    };
  }

  String? Function(String?)? validateRegisterPassword2(BuildContext context, String value, String value2 ) {
    return (value) {
      if (value!.isEmpty) {
        return 'Introduzca contraseña';
      } else if (value.length < 6) {
        return 'La contraseña tiene que ser mínimo de 6 caracteres!';
      } else {
        if(value != value2){
          //log('$value $value2');
          return 'No coinciden las contraseñas';
        }else {
          return null;
        }

      }
    };
  }

  bool isNumeric(String str) {
    Pattern patternInteger = r'^-?[0-9]+$';
    return checkPattern(pattern: patternInteger, value: str);
  }

  bool checkPattern({pattern, value}) {
    RegExp regularCheck = RegExp(pattern);
    return regularCheck.hasMatch(value);
  }
}

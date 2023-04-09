import 'package:flutter/material.dart';

class AppColors {
  //Main
  static const Color lightThemePrimary = Color(0xFFAED6F1);//Color(0xFFC11718);
  static const Color darkThemePrimary = Color(0xFFB7AEF1);//Color(0xFFC11718);

  static const Color accentColorLight = Color(0xFF4b98db);
  static const Color accentColorDark = Color(0xffa64bdb);

  static const Color lightThemePrimaryColor = Color(0xffffffff);
  static const Color darkThemePrimaryColor = Color(0xff212327);

  //Screen
  static const Color lightThemeStatusBarColor = Color(0xFFFAFAFA);
  static const Color darkThemeStatusBarColor = Color(0xFF303030);

  static const Color lightThemeScaffoldBGColor = Color(0xFFFAFAFA);
  static const Color darkThemeScaffoldBGColor = Color(0xFF303030);

  static const Color lightThemeMajorBGColor = Color(0xffffffff);
  static const Color darkThemeMajorBGColor = Color(0xff212327);
  static const Color midnight = Color(0xff1F2024);

  //Text
  static const Color lightThemeBigTextColor = Color(0xff000000);
  static const Color darkThemeBigTextColor = Color(0xfff0f0f0);

  static const Color lightThemeNormalTextColor = Color(0xff000000);
  static const Color darkThemeNormalTextColor = Color(0xfff0f0f0);

  static const Color lightThemeSmallTextColor = Color(0xFF858992);
  static const Color darkThemeSmallTextColor = Color(0xffcccccc);

  //TextField
  static const Color lightThemeTextFieldFillColor = lightThemeScaffoldBGColor;
  static const Color darkThemeTextFieldFillColor = darkThemeScaffoldBGColor;

  static const Color lightThemeTextFieldTextColor = Color(0xff333333);
  static const Color darkThemeTextFieldTextColor = Color(0xfff0f0f0);

  static const Color lightThemeTextFieldHintColor = Color(0xff9b9b9b);
  static const Color darkThemeTextFieldHintColor = Color(0xff9b9b9b);
  //cursor de los textfields
  static const Color lightThemeTextFieldCursorColor = Color(0xff000000);
  static const Color darkThemeTextFieldCursorColor = Color(0xff796cc0);

  static const Color lightThemeTextFieldValidationColor = Color(0xffff0000);
  static const Color darkThemeTextFieldValidationColor = Color(0xffff0000);

  static const Color lightThemeTextFieldBorderColor = Colors.grey;
  static const Color darkThemeTextFieldBorderColor = Colors.grey;
  //static const Color lightThemeTextFieldFocusedBorderColor = Color(0xFFC11718);

  static const Color lightThemeTextFieldErrorBorderColor = Color(0xffff0000);
  static const Color darkThemeTextFieldErrorBorderColor = Color(0xffff0000);

  //borde text field cuando está activado
  static const Color lightThemeTextFieldFocusedBorderColor = Color(0xff8ed7ff);
  static const Color darkThemeTextFieldFocusedBorderColor = Color(0xffa68eff);

  static const Color buttonLightSolid =  Colors.blue;
  static const Color buttonDarkSolid = Color(0xffa68eff);
  //Icon
  static const Color lightThemeIconColor = Color(0xFFAED6F1);
  static const Color darkThemeIconColor = Color(0xFFB7AEF1);

  //Colors
  static const Color lightBlue = Color(0xFF58b9f0);
  static const Color blue = Colors.blue;
  static const Color purple = Color(0xff8b58f0);
  static const Color red = Colors.red;
  static const Color lightRed = Color(0xfffd6c57);
  static const Color lightRed1 = Color(0xfffe457c);
  static const Color white = Color(0xffffffff);
  static const Color lightBlack = Color(0xff333333);
  static const Color pureWhite = Color(0xdeffffff);
  static const Color highlightGray = Color(0xffe4e4e4);
  static const Color highlightWhite = Color(0xffcccccc);
  static const Color yellow = Color(0xffe4b343);
  static const Color bigTitleColor = Color(0xff000000);
  static const Color bigTitleColorDark = Color(0xffcca76a);
  static const Color lightOrange = Color(0xfffe9654);
  static const Color grey = Colors.grey;
  static const Color darkGray = Color(0xff666666);
  static const Color hideGray = Color(0xff9b9b9b);
  static const Color grayWhite = Color(0xfff0f0f0);
  static const Color whiteGray = Color(0x80ffffff);
  static const Color lightBlueSky = Color(0xff00b2ae);
  static const Color lightGray = Color(0xff999999);
  static const Color lightDark = Color(0x3c000000);
  static const Color carbonic = Color(0x1fffffff);
  static const Color toastColor = Color(0xFFC11718);
  static const LinearGradient primaryIngredientColorLight = LinearGradient(
    //colors: [Color(0xFFd74747), Color(0xFFC11718)],
    colors: [Color(0xFF58b9f0),Color(0xFF2196F3)],
    stops: [0, 1],
  );
  static const LinearGradient primaryIngredientColorDark = LinearGradient(
    //colors: [Color(0xFFd74747), Color(0xFFC11718)],
    colors: [Color(0xff8b58f0),Color(0xFF6E21F3)],
    stops: [0, 1],
  );
}

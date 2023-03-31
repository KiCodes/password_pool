import 'package:flutter/material.dart';

import 'constants.dart';




ThemeData lightThemeData (BuildContext context){
  return ThemeData.light().copyWith(

    scaffoldBackgroundColor: kprimary,
    iconTheme: IconThemeData(color: kdarkerblue),
    buttonTheme: ButtonThemeData(colorScheme:
    ColorScheme.light(
      background: Colors.redAccent,
      primary: Colors.black54,
    )),
    colorScheme: ColorScheme.light(
        background: kprimary,
        tertiary: Colors.black38,
        primary: kdarkerblue,
        secondary: Colors.white70),
  );

}

ThemeData darkThemeData (BuildContext context){
  return ThemeData.light().copyWith(

    scaffoldBackgroundColor: kbackground,
    iconTheme: IconThemeData(color: kbackground),
    colorScheme: ColorScheme.dark().copyWith(
        background: kbackground,
        tertiary: Colors.black38,
        primary: Colors.white,
        secondary: Colors.white),
  );

}


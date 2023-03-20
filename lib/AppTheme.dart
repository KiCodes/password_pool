import 'package:flutter/material.dart';

import 'constants.dart';




ThemeData lightThemeData (BuildContext context){
  return ThemeData.light().copyWith(

    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.teal,
    iconTheme: IconThemeData(color: Colors.black38),
    buttonTheme: ButtonThemeData(colorScheme:
    ColorScheme.light(
      background: Colors.redAccent,
      primary: Colors.white,
    )),
    colorScheme: ColorScheme.light(
        background: Colors.teal,
        tertiary: Colors.black38,
        primary: Colors.redAccent,
        secondary: Colors.white70),
  );

}

ThemeData darkThemeData (BuildContext context){
  return ThemeData.light().copyWith(

    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: kbackground,
    iconTheme: IconThemeData(color: Colors.white70),
    colorScheme: ColorScheme.dark().copyWith(
        background: kbackground,
        tertiary: Colors.black38,
        primary: Colors.white,
        secondary: Colors.white),
  );

}


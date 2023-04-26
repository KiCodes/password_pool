import 'package:flutter/material.dart';
import '../utils/constants.dart';

ThemeData lightThemeData(BuildContext context) {
  final Color primaryColor = const Color(0xFF4FC3F7); // Darker blue
  final Color secondaryColor = const Color(0xFFFFA726); // Darker orange
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color lightGreen = const Color(0xFFC8E6C9);

  final ColorScheme colorScheme = ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    background: lightBlue,
    tertiary: lightGreen,
    surface: Colors.white,
    error: const Color(0xFFB00020),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: Colors.black,
    inverseSurface: Colors.white,
    onError: Colors.white,
    inversePrimary: Colors.blue,
    brightness: Brightness.light,
  );


  return ThemeData.from(
    colorScheme: colorScheme,
    textTheme: const TextTheme(),
  ).copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white54),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      buttonColor: secondaryColor,
      disabledColor: colorScheme.onSurface.withOpacity(0.12),
      highlightColor: Colors.transparent,
      splashColor: colorScheme.onSurface.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

ThemeData darkThemeData(BuildContext context) {
  final Color primaryColor = const Color(0xFFFFA726);  // Darker blue
  final Color secondaryColor = const Color(0xFF4FC3F7); // Darker orange
  final Color darkGrey = const Color(0xFF212121);

  final ColorScheme colorScheme = ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: Colors.black,
    background: darkGrey,
    surface: const Color(0xFF121212),
    error: const Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: Colors.white,
    inversePrimary: primaryColor,
    inverseSurface: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
    brightness: Brightness.dark,
  );

  return ThemeData.from(
    colorScheme: colorScheme,
    textTheme: const TextTheme(),
  ).copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white54),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}


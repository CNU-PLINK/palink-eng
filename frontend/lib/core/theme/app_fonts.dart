import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    textTheme: textTheme(),
    appBarTheme: appTheme(),
    primaryColor: Colors.green,
  );
}

AppBarTheme appTheme() {
  return AppBarTheme(
      centerTitle: false,
      color: Colors.white,
      elevation: 0.0,
      titleTextStyle: textTheme().titleMedium);
}

TextTheme textTheme() {
  return const TextTheme(
    displayMedium: TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w300),
    displaySmall: TextStyle(
        fontSize: 13,
        color: Colors.white,
        fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 20.0,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 17.0,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 13.0,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
        fontSize: 17,
        color: Colors.black,
        fontWeight: FontWeight.bold),
    titleMedium: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.bold),
    titleLarge: TextStyle(
        fontSize: 25,
        color: Colors.black,
        fontWeight: FontWeight.bold),
  );
}

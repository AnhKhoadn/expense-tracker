import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: const Color(0xffE9E9E9),
    onBackground: Colors.black87,
    brightness: Brightness.light,
    primary: Colors.grey.shade100,
    onPrimary: Colors.white,
    secondary: Colors.black,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    onBackground: Colors.white,
    brightness: Brightness.dark,
    primary: Colors.grey.shade800,
    onPrimary: Colors.grey.shade800,
    secondary: Colors.white,
  ),
);

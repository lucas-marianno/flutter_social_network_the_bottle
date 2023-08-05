import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.grey[900]!, //
    onPrimary: Colors.grey[200]!, //
    secondary: Colors.grey, //
    onSecondary: Colors.red,
    tertiary: Colors.grey[200],
    error: Colors.grey[900]!,
    onError: Colors.white, //
    background: Colors.grey[300]!, //
    onBackground: Colors.grey[700]!, //
    surface: Colors.grey[100]!, //
    onSurface: Colors.grey[900]!,
    shadow: const Color.fromARGB(75, 189, 189, 189),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.grey[900]!, //
    onPrimary: Colors.grey[200]!, //
    secondary: Colors.grey[400]!, //
    onSecondary: Colors.red,
    tertiary: Colors.grey[800],
    error: Colors.grey[900]!,
    onError: Colors.black45, //
    background: Colors.grey[900]!, //
    onBackground: Colors.grey[300]!, //
    surface: Colors.grey[850]!, //
    onSurface: Colors.grey[100]!,
    shadow: Colors.transparent,
  ),
);

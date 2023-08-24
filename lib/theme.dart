import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.grey[300]!,
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.grey[100],
    linearTrackColor: Colors.grey[200],
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
  ),
  drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[300]),
  dividerTheme: DividerThemeData(color: Colors.grey[400]!),
  colorScheme: ColorScheme.light(
    primary: Colors.grey[900]!,
    surface: Colors.grey[200]!,
    surfaceVariant: Colors.grey[100],
    inverseSurface: const Color.fromARGB(255, 225, 240, 255),
    shadow: const Color.fromARGB(75, 189, 189, 189),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.grey[900],
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.grey[800],
    linearTrackColor: Colors.grey[900],
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
  ),
  drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[900]),
  dividerTheme: DividerThemeData(color: Colors.grey[700]!),
  colorScheme: ColorScheme.dark(
    primary: Colors.grey[200]!,
    surface: Colors.grey[850]!,
    surfaceVariant: Colors.grey[800],
    inverseSurface: const Color.fromARGB(255, 44, 61, 80),
    shadow: Colors.transparent,
  ),
);

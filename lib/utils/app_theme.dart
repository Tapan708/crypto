import 'package:flutter/material.dart';
import 'package:cryto/utils/app_color.dart';
import 'package:cryto/utils/app_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColor.primary,
    scaffoldBackgroundColor: AppColor.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColor.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.bold,
      ),
      iconTheme: IconThemeData(color: AppColor.black),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColor.black87,
        fontFamily: AppFonts.regular,
      ),
      headlineSmall: TextStyle(
        color: AppColor.black,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        fontFamily: AppFonts.bold,
      ),
      bodySmall: TextStyle(
        color: AppColor.black54,
        fontFamily: AppFonts.light,
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColor.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColor.primary,
      foregroundColor: AppColor.white,
    ),
  );
}
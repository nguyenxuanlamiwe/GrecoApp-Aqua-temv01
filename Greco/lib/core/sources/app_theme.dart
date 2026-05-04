import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData defaultThemeData() {
  return ThemeData(
    useMaterial3: false,
    fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppTheme.primaryColor,
      error: AppTheme.errorColor,
    ),
    canvasColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      contentPadding: const EdgeInsets.all(16),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      hintStyle: AppTheme.textStyle(color: AppTheme.$A3A3A3),
    ),
    dividerTheme: const DividerThemeData(
      color: AppTheme.$E1E1E1,
      space: 1,
      thickness: 1,
      indent: 0,
      endIndent: 0,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      foregroundColor: AppTheme.$3A3A3A,
      titleTextStyle: AppTheme.textStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    // textButtonTheme: TextButtonThemeData(style: ButtonStyle(col))
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTheme.textStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.$3A3A3A,
        textStyle: AppTheme.textStyle(fontWeight: FontWeight.w500),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return Colors.white;
        },
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return AppTheme.$A3A3A3;
        },
      ),
    ),
    listTileTheme: const ListTileThemeData(
      horizontalTitleGap: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppTheme.primaryColor,
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: AppTheme.textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: AppTheme.textStyle(
        color: AppTheme.primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelColor: AppTheme.primaryColor,
      labelColor: Colors.white,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppTheme.primaryColor,
      ),
      labelPadding: const EdgeInsets.symmetric(vertical: 10),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.primaryColor),
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryColor;
          }
          return AppTheme.$A3A3A3;
        },
      ),
      thumbColor: MaterialStateProperty.resolveWith(
        (states) {
          return Colors.white;
        },
      ),
    ),
  );
}

class AppTheme {
  AppTheme._();

  static const primaryColor = Color(0xFF1B8D42);
  static const errorColor = Color(0xFFED3131);
  static const $3A3A3A = Color(0xFF3A3A3A);
  static const $F5F5F5 = Color(0xFFF5F5F5);
  static const $F3F3F3 = Color(0xFFF3F3F3);
  static const $E1E1E1 = Color(0xFFE1E1E1);
  static const $A3A3A3 = Color(0xFFA3A3A3);
  static const $E8E8E8 = Color(0xFFE8E8E8);
  static const $F6F6F6 = Color(0xFFF6F6F6);
  static const $464646 = Color(0xFF464646);
  static const $666666 = Color(0xFF666666);
  static const $F8D416 = Color(0xFFF8D416);
  static const $FF9900 = Color(0xFFFF9900);

  static TextStyle textStyle({
    Color? color = $3A3A3A,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return GoogleFonts.beVietnamPro(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }
}

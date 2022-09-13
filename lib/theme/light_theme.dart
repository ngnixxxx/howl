import 'package:flutter/material.dart';
import 'package:howl/utils/constants.dart';

ThemeData lightTheme = ThemeData(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  backgroundColor: primary,
  dialogBackgroundColor: primary,
  scaffoldBackgroundColor: primary,
  bottomAppBarColor: primary,
  cardColor: primary,
  accentColor: accent,
  primaryColor: primary,
  splashColor: accent.withOpacity(0.15),
  hoverColor: accent.withOpacity(0.15),
  focusColor: accent,
  indicatorColor: accent,
  highlightColor: accent.withOpacity(0.15),
  accentIconTheme: IconThemeData(color: Colors.white, size: 24),
  primaryIconTheme: IconThemeData(color: text, size: 24),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: accent,
    actionTextColor: Colors.white,
    contentTextStyle: TextStyle(color: text, letterSpacing: 1.2),
    behavior: SnackBarBehavior.floating,
  ),
  toggleableActiveColor: accent,
  textTheme: TextTheme(
    bodyText1:
        TextStyle(color: text, letterSpacing: 1.2, fontFamily: 'Poppins'),
    bodyText2: TextStyle(
        color: Colors.white, letterSpacing: 1.2, fontFamily: 'Poppins'),
    subtitle2:
        TextStyle(color: text, letterSpacing: 1.2, fontFamily: 'Poppins'),
    subtitle1: TextStyle(
        color: Colors.white, letterSpacing: 1.2, fontFamily: 'Poppins'),
    button: TextStyle(color: accent.withOpacity(0.5), fontFamily: 'Cabin'),
    caption: TextStyle(color: text),
    headline1: TextStyle(color: text, fontFamily: 'Cabin'),
    headline2: TextStyle(color: text, fontFamily: 'Cabin'),
    headline3: TextStyle(color: text, fontFamily: 'Cabin'),
    headline4: TextStyle(color: text, fontFamily: 'Cabin'),
    headline5: TextStyle(
        color: text, fontFamily: 'Cabin', fontWeight: FontWeight.w800),
    headline6: TextStyle(
        color: text, fontFamily: 'Cabin', fontWeight: FontWeight.w800),
  ),
  buttonBarTheme: ButtonBarThemeData(),
  buttonTheme: ButtonThemeData(
    buttonColor: accent,
    disabledColor: Colors.grey,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(
    color: accent,
    fillColor: accent,
  ),
  buttonColor: accent,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: accent),
  appBarTheme: AppBarTheme(
      elevation: 0,
      actionsIconTheme: IconThemeData(color: text, size: 25),
      iconTheme: IconThemeData(color: text, size: 25),
      textTheme: TextTheme(
        headline6: TextStyle(
          color: text,
          fontSize: 20,
        ),
      )),
  dividerTheme: DividerThemeData(
    color: text,
    thickness: 0.5,
    indent: 20,
    endIndent: 20,
  ),
  cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  bottomSheetTheme: BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 3,
    type: BottomNavigationBarType.fixed,
    backgroundColor: primary,
    unselectedIconTheme: IconThemeData(color: text.withOpacity(0.5)),
    selectedIconTheme: IconThemeData(color: text),
    selectedLabelStyle: TextStyle(color: text),
    unselectedLabelStyle: TextStyle(color: text.withOpacity(0.5)),
  ),
  selectedRowColor: accent.withOpacity(0.15),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: secondary.withOpacity(0.7),
    labelStyle: TextStyle(
      color: accent,
    ),
    alignLabelWithHint: true,
    counterStyle: TextStyle(color: accent),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade900)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accent)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red)),
  ),
);

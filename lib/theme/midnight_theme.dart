import 'package:flutter/material.dart';
import 'package:howl/utils/constants.dart';

ThemeData midnightTheme = ThemeData(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  backgroundColor: primaryMidnight,
  dialogBackgroundColor: primaryMidnight,
  scaffoldBackgroundColor: primaryMidnight,
  bottomAppBarColor: primaryMidnight,
  cardColor: primaryMidnight,
  accentColor: accentMidnight,
  primaryColor: primaryMidnight,
  toggleableActiveColor: accentMidnight,
  hoverColor: accentMidnight.withOpacity(0.15),
  focusColor: accentMidnight,
  indicatorColor: accentMidnight,
  highlightColor: accentMidnight.withOpacity(0.15),
  selectedRowColor: accentMidnight.withOpacity(0.15),
  iconTheme: IconThemeData(color: primary, size: 24),
  accentIconTheme: IconThemeData(color: primaryMidnight, size: 24),
  primaryIconTheme: IconThemeData(color: primary, size: 24),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: accentMidnight,
    actionTextColor: primaryMidnight,
    contentTextStyle: TextStyle(color: text),
    behavior: SnackBarBehavior.floating,
  ),
  cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  textTheme: TextTheme(
    bodyText1:
        TextStyle(color: primary, letterSpacing: 1.2, fontFamily: 'Poppins'),
    bodyText2: TextStyle(
        color: Colors.black87, letterSpacing: 1.2, fontFamily: 'Poppins'),
    subtitle2:
        TextStyle(color: primary, letterSpacing: 1.2, fontFamily: 'Poppins'),
    subtitle1: TextStyle(
        color: Colors.black87, letterSpacing: 1.2, fontFamily: 'Poppins'),
    button: TextStyle(color: Colors.black87, fontFamily: 'Cabin'),
    caption: TextStyle(color: primary, fontFamily: 'Poppins'),
    headline1: TextStyle(color: primary, fontFamily: 'Cabin'),
    headline2: TextStyle(color: primary, fontFamily: 'Cabin'),
    headline3: TextStyle(color: primary, fontFamily: 'Cabin'),
    headline4: TextStyle(color: primary, fontFamily: 'Cabin'),
    headline5: TextStyle(
        color: primary, fontFamily: 'Cabin', fontWeight: FontWeight.w800),
    headline6: TextStyle(
        color: primary, fontFamily: 'Cabin', fontWeight: FontWeight.w800),
  ),
  buttonBarTheme: ButtonBarThemeData(),
  buttonTheme: ButtonThemeData(
    buttonColor: accentMidnight,
    splashColor: accentMidnight.withOpacity(0.3),
    disabledColor: primary.withOpacity(0.8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(
      color: accentMidnight.withOpacity(0.6),
      borderColor: accentMidnight.withOpacity(0.6),
      fillColor: accentMidnight.withOpacity(0.6),
      selectedBorderColor: accentMidnight,
      selectedColor: accentMidnight),
  buttonColor: accentMidnight,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: accentMidnight,
    disabledElevation: 0,
  ),
  appBarTheme: AppBarTheme(
      elevation: 0,
      color: primaryMidnight,
      iconTheme: IconThemeData(color: primary, size: 25),
      textTheme: TextTheme(
        headline6: TextStyle(
          color: primary,
          fontSize: 20,
        ),
      )),
  dividerTheme: DividerThemeData(
    color: accentMidnight,
    thickness: 0.5,
    indent: 20,
    endIndent: 20,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: primaryMidnight,
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
      backgroundColor: primaryMidnight,
      unselectedIconTheme:
          IconThemeData(color: accentMidnight.withOpacity(0.5)),
      selectedIconTheme: IconThemeData(color: accentMidnight),
      selectedLabelStyle: TextStyle(color: accentMidnight),
      unselectedLabelStyle: TextStyle(color: accentMidnight.withOpacity(0.5))),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: primary.withOpacity(0.4),
    labelStyle: TextStyle(
      color: primary,
    ),
    hintStyle: TextStyle(
      color: primary,
    ),
    alignLabelWithHint: true,
    counterStyle: TextStyle(color: accentMidnight),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade400)),
  ),
);

import 'package:flutter/material.dart';
import 'package:howl/utils/constants.dart';

ThemeData darkTheme = ThemeData(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.dark,
  backgroundColor: primaryDark,
  dialogBackgroundColor: primaryDark,
  scaffoldBackgroundColor: primaryDark,
  bottomAppBarColor: primaryDark,
  cardColor: primaryDark,
  accentColor: accentDark,
  primaryColor: primaryDark,
  toggleableActiveColor: accentDark,
  hoverColor: accentDark.withOpacity(0.15),
  focusColor: accentDark,
  indicatorColor: accentDark,
  highlightColor: accentDark.withOpacity(0.15),
  selectedRowColor: accentDark.withOpacity(0.15),
  accentIconTheme: IconThemeData(color: primaryDark, size: 24),
  primaryIconTheme: IconThemeData(color: primary, size: 24),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: accentDark,
    actionTextColor: primaryDark,
    contentTextStyle: TextStyle(color: primaryDark.withOpacity(0.8)),
    behavior: SnackBarBehavior.floating,
  ),
  cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  textTheme: TextTheme(
    bodyText1:
        TextStyle(color: primary, letterSpacing: 1.2, fontFamily: 'Poppins'),
    bodyText2: TextStyle(
        color: primaryDark, letterSpacing: 1.2, fontFamily: 'Poppins'),
    subtitle2:
        TextStyle(color: primary, letterSpacing: 1.2, fontFamily: 'Poppins'),
    subtitle1: TextStyle(
        color: primaryDark, letterSpacing: 1.2, fontFamily: 'Poppins'),
    button: TextStyle(color: primaryDark, fontFamily: 'Cabin'),
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
    buttonColor: accentDark,
    textTheme: ButtonTextTheme.primary,
    disabledColor: primary.withOpacity(0.8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(),
  buttonColor: accentDark,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: accentDark,
    disabledElevation: 0,
  ),
  appBarTheme: AppBarTheme(
      elevation: 0,
      color: primaryDark,
      iconTheme: IconThemeData(color: primary, size: 25),
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.white70,
          fontSize: 20,
        ),
      )),
  dividerTheme: DividerThemeData(
    color: accentDark,
    thickness: 0.5,
    indent: 20,
    endIndent: 20,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: primaryDark,
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
    backgroundColor: primaryDark,
    unselectedIconTheme: IconThemeData(color: accentDark.withOpacity(0.5)),
    selectedIconTheme: IconThemeData(color: accentDark),
    selectedLabelStyle: TextStyle(color: accentDark),
    unselectedLabelStyle: TextStyle(color: accentDark.withOpacity(0.5)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: primary.withOpacity(0.4),
    labelStyle: TextStyle(
      color: primary,
    ),
    alignLabelWithHint: true,
    counterStyle: TextStyle(color: primary),
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

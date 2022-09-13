import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:howl/theme/backend_theme_types.dart';
import 'package:howl/theme/theme_types.dart';

import 'dark_theme.dart';
import 'light_theme.dart';
import 'midnight_theme.dart';

abstract class AppTheme extends ChangeNotifier {
  ThemeType themeType;
  bool useSystem;
  Box themeDb;

  AppTheme({
    this.themeType = ThemeType.LIGHT,
    this.useSystem = true,
  }) : super() {
    loadSettings();
    saveSettings();
  }

  Future<void> initialize() async {
    themeDb = await Hive.openBox('theme');
    await loadSettings();
    notifyListeners();
  }

  void setThemeType(ThemeType type) {
    useSystem = false;
    themeType = type;
    saveSettings();
    notifyListeners();
  }

  void setUseSystem(bool val) {
    useSystem = val;
    saveSettings();
    notifyListeners();
  }

  ThemeData getCustomTheme() {
    switch (themeType) {
      case ThemeType.LIGHT:
        return lightTheme;
      case ThemeType.DARK:
        return darkTheme;
      case ThemeType.MIDNIGHT:
        return midnightTheme;
      default:
        return lightTheme;
    }
  }

  ThemeData getLightTheme() {
    if (useSystem) {
      return lightTheme;
    } else {
      return getCustomTheme();
    }
  }

  ThemeData getDarkTheme() {
    if (useSystem) {
      return darkTheme;
    } else {
      return getCustomTheme();
    }
  }

  BackendThemeType getRequiredService();
  Future<void> loadSettings();
  Future<void> saveSettings();
}

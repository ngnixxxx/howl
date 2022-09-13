import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:howl/theme/app_theme.dart';
import 'package:howl/theme/backend_theme_types.dart';
import 'package:howl/theme/theme_types.dart';

class ThemeService extends AppTheme {
  Box themeDb;

  Map<String, ThemeType> themeTypeLookup = {
    'light': ThemeType.LIGHT,
    'dark': ThemeType.DARK,
    'midnight': ThemeType.MIDNIGHT,
  };
  Map<ThemeType, String> themeTypeNameLookup = {
    ThemeType.LIGHT: 'light',
    ThemeType.DARK: 'dark',
    ThemeType.MIDNIGHT: 'midnight',
  };
  @override
  BackendThemeType getRequiredService() {
    return BackendThemeType.HIVE;
  }

  @override
  Future<void> loadSettings() async {
    await Hive.initFlutter();
    themeDb = await Hive.openBox('theme');
    try {
      String themeTypeName = themeDb.get('type');
      themeType = themeTypeLookup[themeTypeName];
      useSystem = themeDb.get('system').toLowerCase() == 'true' ? true : false;
      notifyListeners();
    } catch (e) {
      useSystem = false;
      themeType = ThemeType.LIGHT;
      notifyListeners();
    }
  }

  @override
  Future<void> saveSettings() async {
    await Hive.initFlutter();

    themeDb = await Hive.openBox('theme');
    themeDb.put('type', themeTypeNameLookup[themeType]);
    themeDb.put('system', useSystem.toString());
  }
}

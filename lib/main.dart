import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:howl/email_register.dart';
import 'package:howl/login.dart';
import 'package:howl/pages/messages_page.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/providers/disappearing_image_provider.dart';
import 'package:howl/providers/sending_provider.dart';
import 'package:howl/providers/user_provider.dart';
import 'package:howl/register.dart';
import 'package:howl/theme/app_theme.dart';
import 'package:howl/theme/theme_service.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'models/user_data.dart';

void main() {
  AppTheme appTheme = ThemeService();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserData()),
    ChangeNotifierProvider(create: (context) => appTheme),
    ChangeNotifierProvider(create: (context) => DisappearingImageProvider()),
    ChangeNotifierProvider(create: (context) => SendingProvider()),
    ChangeNotifierProvider(create: (context) => UserProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  static Container onlineCircle = Container(
    height: 10,
    width: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.greenAccent,
    ),
  );

  Widget _getScreenId() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return Home();
        } else {
          return Register();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: Firebase.initializeApp(),
        builder:  (context, snapshot) {
          return Consumer<AppTheme>(
              builder: (BuildContext context, AppTheme appTheme, Widget child) {
                return MaterialApp(
                  initialRoute: '/',
                  routes: {
                    '/register': (context) => Register(),
                    '/home': (context) => Home(),
                    '/messages': (context) => MessagesPage(),
                    '/profile': (context) => ProfilePage(),
                    '/email': (context) => EmailSignUp(),
                    '/login': (context) => Login()
                  },
                  debugShowCheckedModeBanner: false,
                  theme: appTheme.getLightTheme(),
                  darkTheme: appTheme.getDarkTheme(),
                  home: _getScreenId(),
                );
              });
    });
  }
}

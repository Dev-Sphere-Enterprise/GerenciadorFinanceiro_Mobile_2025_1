import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finbuddy/screens/screens_index.dart';
import 'package:finbuddy/shared/core/navigator.dart';
import 'package:finbuddy/shared/core/preferences_manager.dart';
import 'package:finbuddy/shared/core/user_manager.dart';
import 'package:finbuddy/shared/core/user_storage.dart';

class SplashScreenController {
  final BuildContext context;
  bool isFirstTime = false;
  SplashScreenController(this.context);
  final Logger _logger = Logger('Splash screen logger');
  final userStorage = UserStorage();

  void initApplication(Function onComplete) async {
    await Future.delayed(const Duration(seconds: 3), () async {
      await configDefaultAppSettings();
    });
  }

  Future configDefaultAppSettings() async {
    _logger.config('Configuring default app settings...');
    const String loadedKey = 'loadedFirstTime';
    final prefs = await SharedPreferences.getInstance();
    PreferencesManager.saveIsFirstTime();
    setupGetIt();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _logger.fine('Default app settings configured!');
    final bool? isFirstTime = prefs.getBool(loadedKey);
    if (isFirstTime != null && isFirstTime) {
      log('First time user in: carrosel');
      // navigatorKey.currentState!.pushNamed(Screens.carrousel);
    } else {
      log('User already open app: sign in or home');
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        log('Alright, checking firebase auth user');
        if (user == null) {
          log('User is $user');
          navigatorKey.currentState!.pushReplacementNamed(Screens.login);
        } else {
          navigatorKey.currentState!.pushReplacementNamed(Screens.home);
        }
      });
      return;
    }
  }

  void setupGetIt() {
    final getIt = GetIt.instance;
    getIt.registerSingleton<UserManager>(UserManager());
  }
}

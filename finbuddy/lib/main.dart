import 'package:finbuddy/app.dart';
import 'package:finbuddy/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/Login/login_screen.dart';
import 'screens/Register/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/Home/home_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}



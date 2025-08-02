import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Novo import para Firestore
import 'package:google_sign_in/google_sign_in.dart';
import '../../Login/login_screen.dart';
import '../../Home/home_screen.dart';
import 'package:intl/intl.dart';


Future<void> registerWithGoogle({
  required BuildContext context,
  required Function(String?) setErrorMessage,
}) async {
  try {
    await GoogleSignIn.instance.initialize();
    final googleUser = await GoogleSignIn.instance.authenticate();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken!,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }  on GoogleSignInException catch (e) {
    setErrorMessage('Erro no login com Google: ${e.code}${e.description != null ? ' – ${e.description}' : ''}');
  } catch (e) {
    setErrorMessage('Falha inesperada no login com Google: $e');
  }
}

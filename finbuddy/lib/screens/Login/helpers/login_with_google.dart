import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
Future<void> loginWithGoogle({
  required Function(String?) setErrorMessage,
}) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    final googleUser = await GoogleSignIn.instance.authenticate();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    // navegue para a Home
  } catch (e) {
    setErrorMessage('Erro ao logar com Google: $e');
  }
}

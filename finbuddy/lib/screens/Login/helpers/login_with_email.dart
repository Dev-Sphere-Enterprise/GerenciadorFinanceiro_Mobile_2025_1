import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Home/home_screen.dart';

Future<void> loginWithEmail({
  required BuildContext context,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required Function(String?) setErrorMessage,
  required Function(bool) setLoading,
}) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  setLoading(true);
  setErrorMessage(null);

  try {
    await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } on FirebaseAuthException catch (e) {
    setErrorMessage(e.message);
  } finally {
    setLoading(false);
  }
}

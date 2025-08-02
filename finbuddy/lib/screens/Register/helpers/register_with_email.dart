import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../Home/home_screen.dart';

Future<void> registerWithEmail({
  required BuildContext context,
  required TextEditingController nameController,
  required TextEditingController dobController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
  required Function(bool) setLoading,
  required Function(String?) setErrorMessage,
}) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  setLoading(true);
  setErrorMessage(null);

  if (passwordController.text != confirmPasswordController.text) {
    setErrorMessage('As senhas não coincidem');
    setLoading(false);
    return;
  }

  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': nameController.text.trim(),
      'dob': Timestamp.fromDate(DateFormat('dd/MM/yyyy').parse(dobController.text)),
      'email': emailController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } on FirebaseAuthException catch (e) {
    setErrorMessage(e.message);
  } catch (e) {
    setErrorMessage('Erro inesperado: $e');
  } finally {
    setLoading(false);
  }
}

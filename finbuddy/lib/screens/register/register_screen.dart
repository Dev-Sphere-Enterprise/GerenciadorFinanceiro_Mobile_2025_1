import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Novo import para Firestore
import 'package:google_sign_in/google_sign_in.dart';
import '../Login/login_screen.dart';
import '../Home/home_screen.dart';
import 'package:intl/intl.dart';
import 'helpers/register_with_email.dart';
import 'helpers/register_with_google.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController(); // Data de nascimento (string simples)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Data de Nascimento'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000), // data inicial sugerida
                  firstDate: DateTime(1925),   // data mínima
                  lastDate: DateTime.now(),    // data máxima
                );
                if (pickedDate != null) {
                  setState(() {
                    dobController.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                registerWithEmail(
                  context: context,
                  nameController: nameController,
                  dobController: dobController,
                  emailController: emailController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  setLoading: (value) => setState(() => isLoading = value),
                  setErrorMessage: (msg) => setState(() => errorMessage = msg),
                );
              },
              child: const Text('Criar Conta'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                registerWithGoogle(
                  context: context,
                  setErrorMessage: (msg) => setState(() => errorMessage = msg),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Registrar com Google'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Já tem conta? Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

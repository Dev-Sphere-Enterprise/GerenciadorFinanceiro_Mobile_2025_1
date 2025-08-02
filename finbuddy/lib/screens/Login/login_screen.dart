import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Register/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Home/home_screen.dart';
import 'helpers/login_with_email.dart';
import 'helpers/login_with_google.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool isLoading = false;
  String? errorMessage;
  bool _googleInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () =>loginWithEmail(
                context: context,
                emailController: emailController,
                passwordController: passwordController,
                setErrorMessage: (msg) => setState(() => errorMessage = msg),
                setLoading: (value) => setState(() => isLoading = value),
              ),
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => loginWithGoogle(
                setErrorMessage: (msg) => setState(() => errorMessage = msg),
              ),
              icon: const Icon(Icons.login),
              label: const Text('Entrar com Google'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../register/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../home_screen.dart';

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


  Future<void> loginWithEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
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
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      setState(() => errorMessage = 'Erro ao logar com Google: $e');
    }
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
              onPressed: loginWithEmail,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: loginWithGoogle,
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

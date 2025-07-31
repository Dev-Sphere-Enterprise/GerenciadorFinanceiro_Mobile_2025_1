import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import '../signin/login_screen.dart';
import '../home_screen.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  Future<void> register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Validação simples de senha
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'As senhas não coincidem';
        isLoading = false;
      });
      return;
    }

    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Salvar dados adicionais no Firestore, na coleção 'users'
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'dob': Timestamp.fromDate(DateFormat('dd/MM/yyyy').parse(dobController.text)),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navegar para Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage = 'Erro inesperado: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> registerWithGoogle() async {
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
    } on GoogleSignInException catch (e) {
      setState(() =>
      errorMessage = 'GoogleSignInException: ${e.code} - ${e.description}');
    } catch (e) {
      setState(() => errorMessage = 'Erro ao registrar com Google: $e');
    }
  }

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
              onPressed: register,
              child: const Text('Criar Conta'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: registerWithGoogle,
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

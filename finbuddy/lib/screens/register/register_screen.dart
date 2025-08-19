import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import para o ícone do Google
import '../Login/login_screen.dart';
import 'helpers/register_with_email.dart';
import 'helpers/register_with_google.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

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

  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontFamily: 'JetBrainsMono', color: finBuddyDark);

    return Scaffold(
      backgroundColor: finBuddyLime,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crie sua Conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: finBuddyDark,
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: nameController,
                  decoration: _inputDecoration('Nome Completo'),
                  style: textStyle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  readOnly: true,
                  decoration: _inputDecoration('Data de Nascimento'),
                  style: textStyle,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: _inputDecoration('Email'),
                  style: textStyle,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: _inputDecoration('Senha'),
                  obscureText: true,
                  style: textStyle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: _inputDecoration('Confirmar Senha'),
                  obscureText: true,
                  style: textStyle,
                ),
                const SizedBox(height: 8),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(color: Colors.red[700]),
                    ),
                  ),
                const SizedBox(height: 24),

                isLoading
                    ? const Center(child: CircularProgressIndicator(color: finBuddyDark))
                    : ElevatedButton(
                  style: _buttonStyle(backgroundColor: finBuddyBlue),
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
                  child: const Text(
                    'CRIAR CONTA',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: _buttonStyle(backgroundColor: Colors.white),
                  onPressed: () {
                    registerWithGoogle(
                      context: context,
                      setErrorMessage: (msg) => setState(() => errorMessage = msg),
                    );
                  },
                  icon: SvgPicture.asset('assets/svg/google.svg', height: 20.0),
                  label: Text(
                    'Registrar com Google',
                    style: textStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Já tem conta? Entrar',
                    style: textStyle.copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1925),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: finBuddyBlue,
              onPrimary: Colors.white,
              surface: finBuddyLime,
              onSurface: finBuddyDark,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: finBuddyDark),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: finBuddyDark, width: 2),
      ),
    );
  }

  ButtonStyle _buttonStyle({required Color backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

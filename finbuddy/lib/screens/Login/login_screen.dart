import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Register/register_screen.dart';
import 'helpers/login_with_email.dart';
import 'helpers/login_with_google.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();

    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid =
          emailController.text.trim().isNotEmpty &&
              passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'JetBrainsMono',
      color: finBuddyDark,
    );

    return Scaffold(
      backgroundColor: finBuddyLime,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 64.0,
                color: finBuddyDark,
              ),
              const SizedBox(height: 16),
              const Text(
                'FinBuddy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: finBuddyDark,
                ),
              ),
              const SizedBox(height: 48),

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
              const SizedBox(height: 8),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(color: Colors.red[700]),
                  ),
                ),
              const SizedBox(height: 24),

              isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: finBuddyDark),
              )
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: finBuddyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isFormValid
                    ? () => loginWithEmail(
                  context: context,
                  emailController: emailController,
                  passwordController: passwordController,
                  setErrorMessage: (msg) =>
                      setState(() => errorMessage = msg),
                  setLoading: (value) =>
                      setState(() => isLoading = value),
                )
                    : null, // <-- aqui o botão fica desabilitado
                child: const Text(
                  'ENTRAR',
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
                onPressed: () => loginWithGoogle(
                  setErrorMessage: (msg) => setState(() => errorMessage = msg),
                ),
                icon: SvgPicture.asset(
                  'assets/svg/google.svg',
                  height: 20.0,
                ),
                label: Text(
                  'Entrar com Google',
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text(
                  'Criar conta',
                  style: textStyle.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'JetBrainsMono',
        color: finBuddyDark,
      ),
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

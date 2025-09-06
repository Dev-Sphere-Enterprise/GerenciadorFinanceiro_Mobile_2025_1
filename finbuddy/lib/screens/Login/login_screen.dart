import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../Ganhos/viewmodel/ganhos_viewmodel.dart';
import '../Gastos/viewmodel/gastos_viewmodel.dart';
import '../Home/home_screen.dart';
import '../Home/viewmodel/home_viewmodel.dart';
import '../Register/register_screen.dart';
import 'viewmodel/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro de Autenticação'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
       backgroundColor: finBuddyLime,
       body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
         return SafeArea(
          child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 24.0),
           child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             const Icon(Icons.calculate_rounded, size: 64.0, color: finBuddyDark),
             const SizedBox(height: 16),
             const Text('Fin_Buddy', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 32, fontWeight: FontWeight.bold, color: finBuddyDark)),
             const SizedBox(height: 48),
             TextField(key: const Key('emailField'),
              controller: viewModel.emailController,
              decoration: _inputDecoration('Email'),
              keyboardType: TextInputType.emailAddress,
             ),
             const SizedBox(height: 16),
             TextField( key: const Key('passwordField'),
              controller: viewModel.passwordController,
              decoration: _inputDecoration('Senha'),
              obscureText: true,
             ),
             const SizedBox(height: 8),

             if (viewModel.errorMessage != null)
              Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: Text(viewModel.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.red)),
              ),
             const SizedBox(height: 24),

             if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator(color: finBuddyDark))
             else ...[
              ElevatedButton( key: const Key('loginButton'),
               style: _buttonStyle(backgroundColor: finBuddyBlue),
               onPressed: viewModel.isFormValid ? () async {
                final sucesso = await viewModel.loginWithEmail();
                if (sucesso && context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (_) => const HomeScreen()
                  ));
                }
               } : null,
               child: const Text('ENTRAR', style: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
               style: _buttonStyle(backgroundColor: Colors.white),
               onPressed: () async {
                final sucesso = await viewModel.loginWithGoogle();
                if (sucesso && context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (_) => const HomeScreen()
                  ));
                }
               },
               icon: SvgPicture.asset('assets/svg/google.svg', height: 20.0),
               label: const Text('Entrar com Google', style: TextStyle(fontFamily: 'JetBrainsMono', color: finBuddyDark, fontWeight: FontWeight.bold)),
              ),
             ],
             const SizedBox(height: 20),
             TextButton(
              onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text('Criar conta', style: TextStyle(fontFamily: 'JetBrainsMono', color: finBuddyDark, decoration: TextDecoration.underline)),
             ),
            ],
           ),
          ),
         );
        },
       ),
      );
     }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: finBuddyDark),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: finBuddyDark, width: 2)),
    );
  }

  ButtonStyle _buttonStyle({required Color backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
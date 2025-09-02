import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../Home/home_screen.dart';
import '../Login/login_screen.dart';
import 'viewmodel/register_viewmodel.dart';
const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: finBuddyLime,
        body: Consumer<RegisterViewModel>(
          builder: (context, viewModel, child) {
            final passwordsMismatch = viewModel.passwordController.text.trim().isNotEmpty &&
                                      viewModel.confirmPasswordController.text.trim().isNotEmpty &&
                                      viewModel.passwordController.text.trim() != viewModel.confirmPasswordController.text.trim();

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Crie sua Conta', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 28, fontWeight: FontWeight.bold, color: finBuddyDark)),
                      const SizedBox(height: 32),

                      TextField(controller: viewModel.nameController, decoration: _inputDecoration('Nome Completo'), textInputAction: TextInputAction.next),
                      const SizedBox(height: 16),
                      TextField(controller: viewModel.dobController, readOnly: true, decoration: _inputDecoration('Data de Nascimento'), onTap: () => viewModel.selectDate(context)),
                      const SizedBox(height: 16),
                      TextField(controller: viewModel.emailController, decoration: _inputDecoration('Email'), keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
                      const SizedBox(height: 16),
                      TextField(controller: viewModel.passwordController, decoration: _inputDecoration('Senha'), obscureText: true, textInputAction: TextInputAction.next),
                      const SizedBox(height: 16),
                      TextField(controller: viewModel.confirmPasswordController, decoration: _inputDecoration('Confirmar Senha'), obscureText: true),
                      
                      if (passwordsMismatch)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('As senhas não coincidem.', style: TextStyle(fontFamily: 'JetBrainsMono', color: Colors.red[700], fontSize: 12)),
                        ),

                      const SizedBox(height: 8),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(viewModel.errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'JetBrainsMono', color: Colors.red[700])),
                        ),
                      const SizedBox(height: 24),
                      
                      if (viewModel.isLoading)
                        const Center(child: CircularProgressIndicator(color: finBuddyDark))
                      else
                        ElevatedButton(
                          style: _buttonStyle(viewModel.isFormValid ? finBuddyBlue : finBuddyBlue.withOpacity(0.5)),
                          onPressed: viewModel.isFormValid ? () async {
                            final sucesso = await viewModel.registerWithEmail();
                            if (sucesso && context.mounted) {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                            }
                          } : null,
                          child: const Text('CRIAR CONTA', style: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text('Já tem conta? Entrar', style: TextStyle(fontFamily: 'JetBrainsMono', color: finBuddyDark, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
  
  ButtonStyle _buttonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
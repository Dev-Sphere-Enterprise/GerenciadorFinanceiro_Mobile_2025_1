import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finbuddy/shared/core/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository repository;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  LoginViewModel({required this.repository}) {
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmail() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await repository.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await repository.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Falha ao fazer login com o Google. Tente novamente.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Por favor, tente novamente.';
      case 'invalid-credential':
        return 'Email ou senha inválidos.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

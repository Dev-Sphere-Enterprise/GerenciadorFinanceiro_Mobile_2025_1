import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/core/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  LoginViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = emailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  void _setErrorMessageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        _errorMessage = 'O formato do e-mail é inválido.';
        break;
      case 'user-not-found':
        _errorMessage = 'Nenhum usuário encontrado com este e-mail.';
        break;
      case 'wrong-password':
        _errorMessage = 'Senha incorreta. Por favor, tente novamente.';
        break;
      case 'user-disabled':
        _errorMessage = 'Este usuário foi desativado.';
        break;
      case 'too-many-requests':
        _errorMessage = 'Acesso bloqueado temporariamente. Tente novamente mais tarde.';
        break;
      case 'network-request-failed':
        _errorMessage = 'Erro de conexão. Verifique sua internet.';
        break;
      case 'user-cancelled-by-user':
      case 'CANCELLED':
        _errorMessage = null;
        break;
      default:
        _errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<bool> loginWithEmail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessageFromCode(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signInWithGoogle();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch(e) {
      _setErrorMessageFromCode(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocorreu um erro inesperado.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
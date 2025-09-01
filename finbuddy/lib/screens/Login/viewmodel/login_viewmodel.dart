import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/core/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  LoginViewModel() {
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
      _errorMessage = e.message; 
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
      await _repository.signInWithGoogle(
        setErrorMessage: (message) {
          _errorMessage = message;
          notifyListeners();
        },
      );
      _isLoading = false;
      notifyListeners();
      return true; 
    } on FirebaseAuthException catch(e) {
      if (e.code != 'CANCELLED') {
        _errorMessage = 'Ocorreu um erro ao logar com o Google.';
      }
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
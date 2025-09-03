import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../shared/core/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  DateTime? _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  RegisterViewModel() {
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final allFilled = nameController.text.trim().isNotEmpty &&
                      dobController.text.trim().isNotEmpty &&
                      emailController.text.trim().isNotEmpty &&
                      passwordController.text.trim().isNotEmpty &&
                      confirmPasswordController.text.trim().isNotEmpty;
    
    final passwordsMatch = passwordController.text.trim() == confirmPasswordController.text.trim();
    
    final nextValidState = allFilled && passwordsMatch;

    if (nextValidState != _isFormValid) {
      _isFormValid = nextValidState;
      notifyListeners();
    }
  }
  
  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1925),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _selectedDate = picked;
      dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      _validateForm();
      notifyListeners();
    }
  }

  Future<bool> registerWithEmail() async {
    if (!_isFormValid || _selectedDate == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signUpWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        nome: nameController.text.trim(),
        dob: _selectedDate!,
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

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
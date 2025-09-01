import 'package:flutter/foundation.dart';
import '../../../shared/core/models/usuario_model.dart';
import '../../../shared/core/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UsuarioModel? _user;
  UsuarioModel? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    _user = await _repository.getCurrentUserProfile();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserProfile(String newName, DateTime newDob) async {
    try {
      await _repository.updateUserProfile(newName, newDob);
      _user = _user?.copyWith(nome: newName, dataNascimento: newDob);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erro ao atualizar perfil: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
  }
}
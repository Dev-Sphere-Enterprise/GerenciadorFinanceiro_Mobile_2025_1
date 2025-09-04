import 'package:flutter/foundation.dart';
import '../../../shared/core/models/cartao_model.dart';
import '../../../shared/core/repositories/cartoes_repository.dart';

class CartoesViewModel extends ChangeNotifier {
  final CartoesRepository _repository;

  late Stream<List<CartaoModel>> cartoesStream;

  CartoesViewModel({CartoesRepository? repository}) 
      : _repository = repository ?? CartoesRepository() {
    cartoesStream = _repository.getCartoesStream();
  }

  Future<void> excluirCartao(String cartaoId) async {
    try {
      await _repository.deleteCartao(cartaoId);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao excluir cartão: $e");
    }
  }

  Future<bool> salvarCartao(CartaoModel cartao) async {
    try {
      await _repository.addOrEditCartao(cartao);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar cartão: $e");
      return false;
    }
  }
}
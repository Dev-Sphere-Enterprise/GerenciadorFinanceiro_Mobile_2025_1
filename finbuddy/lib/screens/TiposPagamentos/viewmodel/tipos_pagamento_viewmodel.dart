import 'package:flutter/foundation.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';
import '../../../shared/core/repositories/tipos_pagamento_repository.dart';

class TiposPagamentoViewModel extends ChangeNotifier {
  final TipoPagamentoRepository _repository = TipoPagamentoRepository();

  late Stream<List<TipoPagamentoModel>> tiposUsuarioStream;
  List<TipoPagamentoModel> _tiposGerais = [];
  List<TipoPagamentoModel> get tiposGerais => _tiposGerais;

  TiposPagamentoViewModel() {
    tiposUsuarioStream = _repository.getTiposStream();
    _loadTiposGerais();
  }

  Future<void> _loadTiposGerais() async {
    try {
      _tiposGerais = await _repository.getTiposGerais();
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar tipos gerais: $e");
    }
  }

  Future<void> excluirTipo(String tipoId) async {
    await _repository.deleteTipo(tipoId);
  }

  Future<bool> salvarTipo(TipoPagamentoModel tipo) async {
    try {
      await _repository.addOrEditTipo(tipo);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar tipo de pagamento: $e");
      return false;
    }
  }
}
import 'package:flutter/foundation.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';
import '../../../shared/core/repositories/tipos_pagamento_repository.dart';

class TiposPagamentoViewModel extends ChangeNotifier {
  final TiposPagamentoRepository _repository = TiposPagamentoRepository();

  late Stream<List<TipoPagamentoModel>> tiposStream;

  TiposPagamentoViewModel() {
    tiposStream = _repository.getTiposStream();
  }

  Future<void> excluirTipo(String tipoId) async {
    await _repository.deleteTipo(tipoId);
  }

  Future<bool> salvarTipo(TipoPagamentoModel tipo) async {
    try {
      await _repository.addOrEditTipo(tipo);
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar tipo de pagamento: $e");
      return false;
    }
  }
}
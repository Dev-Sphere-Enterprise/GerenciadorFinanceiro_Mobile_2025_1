import 'package:flutter/foundation.dart';
import '../../../shared/core/models/cartao_model.dart';
import '../../../shared/core/models/categoria_model.dart';
import '../../../shared/core/models/gasto_model.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';
import '../../../shared/core/repositories/gastos_repository.dart';
import '../../../shared/core/repositories/categorias_repository.dart';
import '../../../shared/core/repositories/cartoes_repository.dart';
import '../../../shared/core/repositories/tipos_pagamento_repository.dart';

class GastosViewModel extends ChangeNotifier {
  final GastosRepository _repository = GastosRepository();

  late Stream<List<GastoModel>> gastosStream;

  List<CategoriaModel> categorias = [];
  List<CartaoModel> cartoes = [];
  List<TipoPagamentoModel> tiposPagamento = [];
  bool isDialogLoading = false;

  GastosViewModel() {
    gastosStream = _repository.getGastosFixosStream();
  }

  Future<void> loadDialogDependencies() async {
    isDialogLoading = true;
    notifyListeners();
    
    final results = await Future.wait([
      _repository.getCategorias(),
      _repository.getCartoes(),
      _repository.getTiposPagamento(),
    ]);

    categorias = results[0] as List<CategoriaModel>;
    cartoes = results[1] as List<CartaoModel>;
    tiposPagamento = results[2] as List<TipoPagamentoModel>;

    isDialogLoading = false;
    notifyListeners();
  }

  Future<void> excluirGasto(String gastoId) async {
    await _repository.deleteGasto(gastoId);
  }

  Future<bool> salvarGasto(GastoModel gasto) async {
    try {
      final gastoFixo = gasto.copyWith(recorrencia: true);
      await _repository.addOrEditGasto(gastoFixo);
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar gasto: $e");
      return false;
    }
  }
}
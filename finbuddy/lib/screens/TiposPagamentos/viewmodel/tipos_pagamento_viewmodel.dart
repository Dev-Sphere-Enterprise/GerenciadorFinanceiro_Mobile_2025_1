import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';
import '../../../shared/core/repositories/tipos_pagamento_repository.dart';

class TiposPagamentoViewModel extends ChangeNotifier {
  final TipoPagamentoRepository _repository;

  List<TipoPagamentoModel> _tiposGerais = [];
  List<TipoPagamentoModel> _tiposUsuario = [];

  final _combinedStreamController = StreamController<List<TipoPagamentoModel>>.broadcast();
  StreamSubscription? _tiposUsuarioSubscription;

  Stream<List<TipoPagamentoModel>> get tiposCombinadosStream => _combinedStreamController.stream;

  TiposPagamentoViewModel({TipoPagamentoRepository? repository})
      : _repository = repository ?? TipoPagamentoRepository() {
    _tiposUsuarioSubscription = _repository.getTiposStream().listen((tiposUsuario) {
      _tiposUsuario = tiposUsuario;
      _combineAndEmit();
    });
  }

  Future<void> loadTiposGerais() async {
    if (_tiposGerais.isNotEmpty) return;
    try {
      _tiposGerais = await _repository.getTiposGerais();
      _combineAndEmit();
    } catch (e) {
      debugPrint("Erro ao carregar tipos gerais: $e");
      _combinedStreamController.addError(e);
    }
  }

  void _combineAndEmit() {
    final List<TipoPagamentoModel> tiposCombinados = [..._tiposGerais, ..._tiposUsuario];
    _combinedStreamController.add(tiposCombinados);
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

  @override
  void dispose() {
    _tiposUsuarioSubscription?.cancel();
    _combinedStreamController.close();
    super.dispose();
  }
}
import 'package:flutter/foundation.dart';
import '../../../shared/core/models/aporte_meta_model.dart';
import '../../../shared/core/repositories/aportes_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AportesViewModel extends ChangeNotifier {
  final AportesRepository _repository;
  final String metaId;

  late Stream<List<AporteMetaModel>> aportesStream;

  AportesViewModel({required this.metaId, required AportesRepository repository})
      : _repository = repository {
    aportesStream = _repository.getAportesStream(metaId);
  }

  Future<void> excluirAporte(String aporteId) async {
    try {
      await _repository.deleteAporte(metaId, aporteId);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao excluir aporte: $e");
    }
  }

  Future<void> recalcularMeta() async {
    try {
      await _repository.recalcularEAtualizarValorMeta(metaId);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao recalcular meta: $e");
    }
  }

  Future<bool> salvarAporte({required double valor, required DateTime data, String? id}) async {
    try {
      final novoAporte = AporteMetaModel(
        id: id,
        idMeta: metaId,
        valor: valor,
        dataAporte: data,
        dataCriacao: id == null ? DateTime.now() : data, 
        dataAtualizacao: DateTime.now(),
        deletado: false
      );
      
      await _repository.addOrEditAporte(metaId, novoAporte);
      notifyListeners();
      return true; 
    } catch (e) {
      debugPrint("Erro ao salvar o aporte: $e");
      return false; 
    }
  }


}
import 'package:flutter/foundation.dart';
import '../../../shared/core/models/aporte_meta_model.dart';
import '../../../shared/core/repositories/aportes_repository.dart';

class AportesViewModel extends ChangeNotifier {
  final AportesRepository _repository = AportesRepository();
  final String metaId;

  late Stream<List<AporteMetaModel>> aportesStream;

  AportesViewModel({required this.metaId}) {
    aportesStream = _repository.getAportesStream(metaId);
  }

  Future<void> excluirAporte(String aporteId) async {
    try {
      await _repository.deleteAporte(metaId, aporteId);
    } catch (e) {
      debugPrint("Erro ao excluir aporte: $e");
    }
  }
  
  Future<void> recalcularMeta() async {
      try {
        await _repository.recalcularEAtualizarValorMeta(metaId);
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
      return true; 
    } catch (e) {
      debugPrint("Erro ao salvar o aporte: $e");
      return false; 
    }
  }

  Future<void> atualizarValorMetaComModel({
  required FirebaseFirestore firestore,
  required User currentUser,
  required String metaId,
  }) async {
    final snapshot = await firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('metas')
        .doc(metaId)
        .collection('aportes_meta')
        .where('Deletado', isEqualTo: false)
        .get();

    final aportes = snapshot.docs.map((doc) {
      return AporteMetaModel.fromMap(doc.id, doc.data());
    }).toList();

    double total = aportes.fold(0.0, (somaAnterior, aporte) => somaAnterior + aporte.valor);
    
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('metas')
        .doc(metaId)
        .update({
      'Valor_Atual': total,
      'Data_Atualizacao': Timestamp.now(),
    });
  }
}
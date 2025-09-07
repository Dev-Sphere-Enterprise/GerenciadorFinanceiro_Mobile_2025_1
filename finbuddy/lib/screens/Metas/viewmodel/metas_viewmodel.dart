import 'package:flutter/foundation.dart';
import '../../../shared/core/models/meta_model.dart';
import '../../../shared/core/repositories/metas_repository.dart';

class MetasViewModel extends ChangeNotifier {
  final MetasRepository _repository = MetasRepository();

  late Stream<List<MetaModel>> metasStream;

  MetasViewModel() {
    metasStream = _repository.getMetasStream();
  }

  Future<void> excluirMeta(String metaId) async {
    try {
      await _repository.deleteMeta(metaId);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao excluir meta: $e");
    }
  }

  Future<bool> salvarMeta(MetaModel meta) async {
    try {
      await _repository.addOrEditMeta(meta);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar meta: $e");
      return false;
    }
  }
}
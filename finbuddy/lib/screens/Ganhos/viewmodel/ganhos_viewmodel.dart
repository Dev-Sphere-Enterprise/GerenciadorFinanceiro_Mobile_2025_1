import 'package:flutter/foundation.dart';
import '../../../shared/core/models/ganho_model.dart';
import '../../../shared/core/repositories/ganhos_repository.dart';

class GanhosViewModel extends ChangeNotifier {
  final GanhosRepository _repository = GanhosRepository();

  late Stream<List<GanhoModel>> ganhosStream;

  GanhosViewModel() {
    ganhosStream = _repository.getGanhosFixosStream();
  }

  Future<void> excluirGanho(String ganhoId) async {
    try {
      await _repository.deleteGanho(ganhoId);
    } catch (e) {
      debugPrint("Erro ao excluir ganho: $e");
    }
  }

  Future<bool> salvarGanho(GanhoModel ganho) async {
    try {
      final ganhoFixo = ganho.copyWith(recorrencia: true);
      await _repository.addOrEditGanho(ganhoFixo);
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar ganho: $e");
      return false;
    }
  }
}
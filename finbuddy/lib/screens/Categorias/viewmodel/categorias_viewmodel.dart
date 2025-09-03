import 'package:flutter/foundation.dart';
import '../../../shared/core/models/categoria_model.dart';
import '../../../shared/core/repositories/categorias_repository.dart';

class CategoriasViewModel extends ChangeNotifier {
  final CategoriasRepository _repository = CategoriasRepository();

  late Stream<List<CategoriaModel>> categoriasStream;

  CategoriasViewModel() {
    categoriasStream = _repository.getCategoriasStream();
  }

  Future<void> excluirCategoria(String categoriaId) async {
    try {
      await _repository.deleteCategoria(categoriaId);
    } catch (e) {
      debugPrint("Erro ao excluir categoria: $e");
    }
  }

  Future<bool> salvarCategoria(CategoriaModel categoria) async {
    try {
      await _repository.addOrEditCategoria(categoria);
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar categoria: $e");
      return false;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/categoria_model.dart';
import '../models/grafico_model.dart';
import 'categorias_repository.dart';
import'../models/categoria_expense_model.dart';


class GraficosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CategoriasRepository _categoriasRepository = CategoriasRepository();

  Future<GraficoModel> getChartData(int ano, int mes) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuário não autenticado.");

    final resultados = await Future.wait<dynamic>([
      _carregarGastosPorCategoria(uid, ano, mes),
      _categoriasRepository.getCategoriasStream().first,
    ]);

    final gastosPorCategoria = resultados[0] as Map<String, CategoriaExpenseModel>;
    final todasCategorias = resultados[1] as List<CategoriaModel>;

    final nomesCategorias = <String, String>{
      for (var c in todasCategorias) c.id!: c.nome
    };

    final categoriasComGasto = gastosPorCategoria.entries
        .where((e) => e.value.totalValue > 0 && nomesCategorias.containsKey(e.key))
        .map((e) => MapEntry(e.key, e.value.totalValue))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalValorGastos = gastosPorCategoria.values
        .fold<double>(0.0, (sum, item) => sum + item.totalValue);

    final totalLancamentos = gastosPorCategoria.values
        .fold<int>(0, (sum, item) => sum + item.count);

    return GraficoModel(
      gastosPorCategoria: gastosPorCategoria,
      nomesCategorias: nomesCategorias,
      categoriasComGasto: categoriasComGasto,
      totalValorGastos: totalValorGastos,
      totalLancamentos: totalLancamentos,
    );
  }

  Future<Map<String, CategoriaExpenseModel>> _carregarGastosPorCategoria(
      String uid, int ano, int mes) async {
    final inicioMes = DateTime(ano, mes, 1);
    final fimMes = (mes == 12)
        ? DateTime(ano + 1, 1, 0, 23, 59, 59)
        : DateTime(ano, mes + 1, 0, 23, 59, 59);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('gastos_fixos')
        .where('Data_Compra', isGreaterThanOrEqualTo: inicioMes)
        .where('Data_Compra', isLessThanOrEqualTo: fimMes)
        .where('Deletado', isEqualTo: false)
        .get();

    final Map<String, CategoriaExpenseModel> contagem = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final categoriaId = data['ID_Categoria'] ?? 'sem_categoria';
      final rawValor = data['Valor'];
      final valor = (rawValor is int)
          ? rawValor.toDouble()
          : (rawValor is double ? rawValor : 0.0);

      contagem.update(
        categoriaId,
            (value) => CategoriaExpenseModel(
          count: value.count + 1,
          totalValue: value.totalValue + valor,
        ),
        ifAbsent: () => CategoriaExpenseModel(count: 1, totalValue: valor),
      );
    }
    return contagem;
  }
}
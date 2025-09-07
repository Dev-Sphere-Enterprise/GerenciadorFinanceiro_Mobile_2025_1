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
      _carregarTetoDeGastosTotal(uid, ano, mes),
      _carregarGastosAcumuladosPorDia(uid, ano, mes),
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
        // ignore: avoid_types_as_parameter_names
        .fold<double>(0.0, (sum, item) => sum + item.totalValue);

    final totalLancamentos = gastosPorCategoria.values
        // ignore: avoid_types_as_parameter_names
        .fold<int>(0, (sum, item) => sum + item.count);

    final diasNoMes = _getDiasNoMes(ano, mes);

    final tetoDeGastosTotal = resultados[2] as double;

    final gastosAcumuladosPorDia = resultados[3] as Map<int, double>;

    return GraficoModel(
      tetoDeGastosTotal:tetoDeGastosTotal,
      diasNoMes:diasNoMes,
      gastosAcumuladosPorDia:gastosAcumuladosPorDia,
      gastosPorCategoria: gastosPorCategoria,
      nomesCategorias: nomesCategorias,
      categoriasComGasto: categoriasComGasto,
      totalValorGastos: totalValorGastos,
      totalLancamentos: totalLancamentos,
    );
  }

  Future<Map<int, double>> _carregarGastosAcumuladosPorDia(String uid, int ano, int mes) async {
    final inicioDoMes = DateTime(ano, mes, 1);
    final fimDoMes = DateTime(ano, mes + 1, 0);

    final snapshot = await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('lancamentos')
        .where('data', isGreaterThanOrEqualTo: inicioDoMes)
        .where('data', isLessThanOrEqualTo: fimDoMes)
        .get();

    final Map<int, double> gastosDiarios = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dia = (data['data'] as Timestamp).toDate().day;
      final valor = data['valor'] as double;
      gastosDiarios.update(dia, (valorExistente) => valorExistente + valor, ifAbsent: () => valor);
    }

    // Acumular os gastos por dia
    final Map<int, double> gastosAcumulados = {};
    double acumulado = 0.0;
    for (var i = 1; i <= _getDiasNoMes(ano, mes); i++) {
      acumulado += gastosDiarios[i] ?? 0.0;
      gastosAcumulados[i] = acumulado;
    }

    return gastosAcumulados;
  }

  Future<double> _carregarTetoDeGastosTotal(String uid, int ano, int mes) async {
    final snapshot = await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('categorias')
        .get();

    double tetoTotal = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Map<String, dynamic> tetos = Map.from(data['tetoGastos'] ?? {});
      final tetoMensal = tetos['$ano-$mes'] ?? 0.0;
      tetoTotal += tetoMensal;
    }
    return tetoTotal;
  }

  int _getDiasNoMes(int ano, int mes) {
    final data = DateTime(ano, mes + 1, 0);
    return data.day;
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
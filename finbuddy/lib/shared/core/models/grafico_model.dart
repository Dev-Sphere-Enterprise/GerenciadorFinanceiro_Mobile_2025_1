import 'categoria_expense_model.dart';
class GraficoModel{
  final List<MapEntry<String, double>> categoriasComGasto;
  
  final Map<String, CategoriaExpenseModel> gastosPorCategoria;
  
  final Map<String, String> nomesCategorias;

  final Map<int, double> gastosAcumuladosPorDia;

  final double tetoDeGastosTotal;

  final int diasNoMes;

  final double totalValorGastos;
  
  final int totalLancamentos;

  GraficoModel({
    required this.tetoDeGastosTotal,
    required this.diasNoMes,
    required this.gastosAcumuladosPorDia,
    required this.categoriasComGasto,
    required this.gastosPorCategoria,
    required this.nomesCategorias,
    required this.totalValorGastos,
    required this.totalLancamentos,
  });
}
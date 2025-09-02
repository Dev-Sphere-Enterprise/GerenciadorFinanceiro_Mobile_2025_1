import 'categoria_expense_model.dart';

class GraficoModel{
  final List<MapEntry<String, double>> categoriasComGasto;
  
  final Map<String, CategoriaExpenseData> gastosPorCategoria;
  
  final Map<String, String> nomesCategorias;
  
  final double totalValorGastos;
  
  final int totalLancamentos;

  GraficoModel({
    required this.categoriasComGasto,
    required this.gastosPorCategoria,
    required this.nomesCategorias,
    required this.totalValorGastos,
    required this.totalLancamentos,
  });
}
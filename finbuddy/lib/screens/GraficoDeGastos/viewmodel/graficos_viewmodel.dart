import 'package:flutter/material.dart';
import '../models/grafico_data.dart';
import '../../../shared/core/repositories/graficos_repository.dart';

enum TipoGrafico { pizza, coluna, linha }

class GraficosViewModel extends ChangeNotifier {
  final GraficosRepository _repository = GraficosRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  GraficoData? _chartData;
  GraficoData? get chartData => _chartData;

  int _anoSelecionado = DateTime.now().year;
  int get anoSelecionado => _anoSelecionado;

  int _mesSelecionado = DateTime.now().month;
  int get mesSelecionado => _mesSelecionado;
  
  TipoGrafico _tipoSelecionado = TipoGrafico.coluna;
  TipoGrafico get tipoSelecionado => _tipoSelecionado;

  int? _indiceSelecionado;
  int? get indiceSelecionado => _indiceSelecionado;

  GraficosViewModel() {
    loadChartData();
  }

  Future<void> loadChartData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _chartData = await _repository.getChartData(_anoSelecionado, _mesSelecionado);
    } catch (e) {
      debugPrint("Erro ao carregar dados do gráfico: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeMonth(int newMonth) {
    _mesSelecionado = newMonth;
    _indiceSelecionado = null;
    loadChartData();
  }

  void changeChartType(TipoGrafico newType) {
    _tipoSelecionado = newType;
    notifyListeners();
  }

  void onPieSectionTouched(int? index) {
    _indiceSelecionado = index;
    notifyListeners();
  }
}
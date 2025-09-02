import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/constants/style_constants.dart';

Widget construirGraficoPizza(
  List<MapEntry<String, double>> categoriasComGasto,
  int? indiceSelecionado,
  Function(int? index) onTap,
) {
  final double totalValue = categoriasComGasto.fold(0.0, (sum, item) => sum + item.value);

  return PieChart(
    PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      startDegreeOffset: -90,
      pieTouchData: PieTouchData(
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
            onTap(null);
            return;
          }
          onTap(response.touchedSection!.touchedSectionIndex);
        },
      ),
      sections: List.generate(categoriasComGasto.length, (index) {
        final item = categoriasComGasto[index];
        final selecionado = index == indiceSelecionado;
        
        final cor = kChartColors[index % kChartColors.length];
        
        final percentage = totalValue > 0 ? (item.value / totalValue) * 100 : 0;

        return PieChartSectionData(
          color: cor,
          value: item.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: selecionado ? 70 : 60,
          titleStyle: estiloFonteMonospace.copyWith(
            fontSize: selecionado ? 16 : 12,
            color: Colors.white,
          ),
        );
      }),
    ),
  );
}
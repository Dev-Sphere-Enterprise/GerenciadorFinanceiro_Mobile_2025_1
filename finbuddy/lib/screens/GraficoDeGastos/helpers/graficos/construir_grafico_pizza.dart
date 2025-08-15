import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget construirGraficoPizza(
    List<MapEntry<String, int>> categoriasComGasto,
    int? indiceSelecionado,
    Function(int? index) onTap,
    ) {
  return PieChart(
    PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: List.generate(categoriasComGasto.length, (index) {
        final valor = categoriasComGasto[index].value;
        final selecionado = index == indiceSelecionado;
        final cor = Colors.primaries[index % Colors.primaries.length];

        return PieChartSectionData(
          color: cor,
          value: valor.toDouble(),
          title: selecionado ? '$valor' : '',
          radius: selecionado ? 70 : 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }),
      pieTouchData: PieTouchData(
        touchCallback: (event, response) {
          if (response != null && response.touchedSection != null) {
            onTap(response.touchedSection!.touchedSectionIndex);
          } else {
            onTap(null);
          }
        },
      ),
    ),
  );
}
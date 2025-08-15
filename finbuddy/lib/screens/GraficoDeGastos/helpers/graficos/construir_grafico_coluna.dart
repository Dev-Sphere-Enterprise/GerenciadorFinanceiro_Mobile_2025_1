import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget construirGraficoColuna(
    List<MapEntry<String, int>> categoriasComGasto,
    Map<String, String> nomesCategorias,
    ) {
  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barGroups: List.generate(categoriasComGasto.length, (index) {
        final categoriaId = categoriasComGasto[index].key;
        final valor = categoriasComGasto[index].value;
        final cor = Colors.primaries[index % Colors.primaries.length];

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: valor.toDouble(),
              color: cor,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value < 0 || value >= categoriasComGasto.length) {
                return const SizedBox.shrink();
              }
              final categoriaId = categoriasComGasto[value.toInt()].key;
              final nome = nomesCategorias[categoriaId] ?? '';
              return Text(
                nome.length > 5 ? '${nome.substring(0, 5)}…' : nome,
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ),
  );
}
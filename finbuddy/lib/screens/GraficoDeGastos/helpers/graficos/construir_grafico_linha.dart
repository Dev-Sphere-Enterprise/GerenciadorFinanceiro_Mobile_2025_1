import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget construirGraficoLinha(
  List<MapEntry<String, int>> categoriasComGasto,
  Map<String, String> nomesCategorias,
) {
  final spots = List.generate(categoriasComGasto.length, (index) {
    final valor = categoriasComGasto[index].value;
    return FlSpot(index.toDouble(), valor.toDouble());
  });

  return LineChart(
    LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true, 
          color: Colors.blue, 
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false), 
          belowBarData: BarAreaData(
            show: true, 
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40, 
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              if (value < 0 || value >= categoriasComGasto.length) {
                return const SizedBox.shrink(); 
              }
              final categoriaId = categoriasComGasto[value.toInt()].key;
              final nome = nomesCategorias[categoriaId] ?? '';
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  nome.length > 5 ? '${nome.substring(0, 5)}…' : nome,
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false, 
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
          left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      ),
    ),
  );
}
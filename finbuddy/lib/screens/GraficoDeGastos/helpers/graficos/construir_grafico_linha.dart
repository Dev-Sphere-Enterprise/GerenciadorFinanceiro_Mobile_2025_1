import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

Widget construirGraficoLinha(
  List<MapEntry<String, int>> categoriasComGasto,
  Map<String, String> nomesCategorias,
) {
  if (categoriasComGasto.isEmpty) {
    return const Center(
      child: Text(
        'Sem dados para exibir no período.',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  final spots = List.generate(categoriasComGasto.length, (index) {
    final valor = categoriasComGasto[index].value;
    return FlSpot(index.toDouble(), valor.toDouble());
  });

  final double valorMaximo =
      spots.map((spot) => spot.y).reduce(max);
  final double maxYComRespiro = valorMaximo * 1.2;

  return LineChart(
    LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipStyle: TooltipStyle(
            backgroundColor: Colors.blueGrey.withOpacity(0.8),
          ),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                'R\$ ${spot.y.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      minY: 0,
      maxY: maxYComRespiro == 0 ? 100 : maxYComRespiro,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.cyanAccent,
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.withOpacity(0.3),
                Colors.cyanAccent.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            interval: maxYComRespiro > 0 ? maxYComRespiro / 4 : 25,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= categoriasComGasto.length) {
                return const SizedBox.shrink();
              }
              final categoriaId = categoriasComGasto[value.toInt()].key;
              final nome = nomesCategorias[categoriaId] ?? '';
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  nome.length > 5 ? '${nome.substring(0, 5)}…' : nome,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
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
      borderData: FlBorderData(show: false),
    ),
  );
}
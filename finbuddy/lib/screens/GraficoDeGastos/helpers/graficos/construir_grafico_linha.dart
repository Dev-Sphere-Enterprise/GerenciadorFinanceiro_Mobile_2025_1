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
      spots.isEmpty ? 0 : spots.map((spot) => spot.y).reduce(max);
  final double maxYComRespiro = valorMaximo * 1.2;

  return LineChart(
    LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
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
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false), 
          gradient: const LinearGradient(
            colors: [
              Colors.greenAccent,
              Colors.orangeAccent,
              Colors.redAccent,
            ],
            stops: [0.0, 0.5, 1.0], 
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.withOpacity(0.3),
                Colors.redAccent.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],

      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 45),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= categoriasComGasto.length) {
                return const SizedBox.shrink();
              }
              final categoriaId = categoriasComGasto[index].key;
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

      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ),
  );
}
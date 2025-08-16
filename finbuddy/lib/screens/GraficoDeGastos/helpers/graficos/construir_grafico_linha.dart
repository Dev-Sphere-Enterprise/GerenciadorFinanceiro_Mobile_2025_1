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

  final double valorMaximo =
      categoriasComGasto.map((e) => e.value).reduce(max).toDouble();

  const corMinima = Colors.greenAccent;
  const corMaxima = Colors.redAccent;

  return BarChart(
    BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.blueGrey.withOpacity(0.8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final valor = rod.toY;
            return BarTooltipItem(
              'R\$ ${valor.toStringAsFixed(2)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),

      barGroups: List.generate(categoriasComGasto.length, (index) {
        final item = categoriasComGasto[index];
        final valor = item.value.toDouble();

        final double t = valorMaximo > 0 ? (valor / valorMaximo) : 0.0;
        final corBarra = Color.lerp(corMinima, corMaxima, t);

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: valor,
              color: corBarra, 
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }),

      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= categoriasComGasto.length) return const SizedBox.shrink();
              final categoriaId = categoriasComGasto[index].key;
              final nome = nomesCategorias[categoriaId] ?? '';
              return Padding(
                padding: const EdgeInsets.only(top: 6.0),
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
      
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ),
  );
}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../../../shared/constants/style_constants.dart';

Widget construirGraficoLinha(
    List<FlSpot> gastosSpots,
    List<FlSpot> tetoSpots,
    ) {
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: '');

  final double maxGastos =
  gastosSpots.isEmpty ? 0 : gastosSpots.map((spot) => spot.y).reduce(max);
  final double maxTeto =
  tetoSpots.isEmpty ? 0 : tetoSpots.map((spot) => spot.y).reduce(max);
  final double valorMaximo = max(maxGastos, maxTeto);
  final double maxYComRespiro = valorMaximo * 1.2;

  // MUDANÇA AQUI: A função agora retorna apenas o widget Text, sem SideTitleWidget.
  Widget EixoY(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) return Container(); // Esconde o primeiro e último para não sobrepor
    return Text(
      formatadorMoeda.format(value),
      style: estiloFonteMonospace.copyWith(
          fontSize: 10, fontWeight: FontWeight.normal),
    );
  }

  // MUDANÇA AQUI: A função agora retorna apenas o widget Text, sem SideTitleWidget.
  Widget EixoX(double value, TitleMeta meta) {
    // Mostra apenas os dias 1, 5, 10, 15, 20, 25, 30
    if (value.toInt() == 1 || value.toInt() % 5 != 0) return Container();
    return Text(
      value.toInt().toString(),
      style: estiloFonteMonospace.copyWith(
          fontSize: 10, fontWeight: FontWeight.normal),
    );
  }

  return LineChart(
    LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: gastosSpots,
          isCurved: false,
          color: Colors.redAccent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: tetoSpots,
          isCurved: false,
          color: finBuddyBlue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          //tooltipBgColor: finBuddyDark,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final label = spot.barIndex == 0 ? 'Gasto:' : 'Teto:';
              return LineTooltipItem(
                  '$label R\$ ${spot.y.toStringAsFixed(2)}\n',
                  estiloFonteMonospace.copyWith(
                      color: Colors.white, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Dia ${spot.x.toInt()}',
                      style: estiloFonteMonospace.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.normal),
                    ),
                  ]);
            }).toList();
          },
        ),
      ),
      minY: 0,
      maxY: maxYComRespiro == 0 ? 100 : maxYComRespiro,
      minX: 1,
      maxX: 30,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
        getDrawingVerticalLine: (_) =>
            FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
          left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
        ),
      ),
      titlesData: FlTitlesData(
        // MUDANÇA AQUI: A propriedade 'space' foi movida para dentro de SideTitles.
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: EixoY)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: EixoX)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    ),
  );
}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../../../shared/constants/style_constants.dart';

Widget construirGraficoLinha(
    List<FlSpot> gastosSpots,
    List<FlSpot> tetoSpots,
    int diasNoMes,
    ) {
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: '');

  final double maxGastos =
  gastosSpots.isEmpty ? 0 : gastosSpots.map((spot) => spot.y).reduce(max);
  final double maxTeto =
  tetoSpots.isEmpty ? 0 : tetoSpots.map((spot) => spot.y).reduce(max);
  final double valorMaximo = max(maxGastos, maxTeto);
  final double maxYComRespiro = valorMaximo * 1.2;

  // ignore: non_constant_identifier_names
  Widget EixoY(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) return Container();
    return Text(
      formatadorMoeda.format(value),
      style: estiloFonteMonospace.copyWith(
          fontSize: 10, fontWeight: FontWeight.normal),
    );
  }

  // ignore: non_constant_identifier_names
  Widget EixoX(double value, TitleMeta meta) {
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
      maxX: diasNoMes.toDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (_) =>
            // ignore: deprecated_member_use
            FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
        getDrawingVerticalLine: (_) =>
            // ignore: deprecated_member_use
            FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          // ignore: deprecated_member_use
          bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
          // ignore: deprecated_member_use
          left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2),
        ),
      ),
      titlesData: FlTitlesData(
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
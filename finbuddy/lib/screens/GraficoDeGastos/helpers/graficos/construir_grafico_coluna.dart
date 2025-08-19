import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

const List<Color> _barColors = [
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.orangeAccent,
  Colors.purpleAccent,
  Colors.redAccent,
  Colors.cyanAccent,
];

Widget construirGraficoColuna(
    List<MapEntry<String, double>> categoriasComGasto,
    Map<String, String> nomesCategorias,
    Map<String, IconData> iconesCategorias,
    ) {
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          //tooltipBgColor: finBuddyDark,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final valorFormatado = formatadorMoeda.format(rod.toY);
            return BarTooltipItem(
              valorFormatado,
              estiloFonteMonospace.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= categoriasComGasto.length) {
                return const SizedBox.shrink();
              }
              final categoriaId = categoriasComGasto[index].key;
              final iconData = iconesCategorias[categoriaId] ?? Icons.label_outline;

              return Icon(iconData, color: finBuddyDark, size: 24);
            },
          ),
        ),
      ),
      barGroups: List.generate(categoriasComGasto.length, (index) {
        final valor = categoriasComGasto[index].value;
        final cor = _barColors[index % _barColors.length];

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: valor,
              color: cor,
              width: 22,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
    ),
  );
}
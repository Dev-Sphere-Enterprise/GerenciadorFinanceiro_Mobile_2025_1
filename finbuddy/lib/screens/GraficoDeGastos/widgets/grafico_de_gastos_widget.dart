import 'package.flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/constants/style_constants.dart';
import '../graficos/construir_grafico_coluna.dart';
import '../graficos/construir_grafico_linha.dart';
import '../graficos/construir_grafico_pizza.dart';
import '../models/grafico_model.dart';
import '../viewmodel/graficos_viewmodel.dart';
import '../grafico_de_gastos_screen.dart';

class GraficoDeGastosWidget extends StatelessWidget {
  final int? limiteCategorias;
  const GraficoDeGastosWidget({super.key, this.limiteCategorias});

  @override
  Widget build(BuildContext context) {
    return Consumer<GraficosViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator(color: finBuddyDark));
        }
        if (viewModel.chartData == null) {
          return const Center(child: Text('Erro ao carregar dados.', style: estiloFonteMonospace));
        }

        final dados = viewModel.chartData!;
        return Column(
          children: [
            Text('Gráfico de Gastos', style: estiloFonteMonospace.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildMonthSelector(context, viewModel),
            const SizedBox(height: 16),
            if (dados.categoriasComGasto.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Nenhum gasto neste mês.', style: estiloFonteMonospace),
                ),
              )
            else
              _buildChartAndSummary(context, viewModel, dados),
          ],
        );
      },
    );
  }

  Widget _buildMonthSelector(BuildContext context, GraficosViewModel viewModel) {
    const meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(12, (index) {
          final mes = index + 1;
          final selecionado = mes == viewModel.mesSelecionado;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () => viewModel.changeMonth(mes),
              child: Text(
                meses[index],
                style: estiloFonteMonospace.copyWith(
                  fontSize: 18,
                  color: selecionado ? finBuddyBlue : finBuddyDark.withOpacity(0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartAndSummary(BuildContext context, GraficosViewModel viewModel, GraficoData dados) {
    final itemCount = limiteCategorias != null
        ? (dados.categoriasComGasto.length > limiteCategorias! ? limiteCategorias! : dados.categoriasComGasto.length)
        : dados.categoriasComGasto.length;

    return Column(
      children: [
        _buildChartTypeSelector(viewModel),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: _buildSelectedChart(viewModel, dados)),
        const SizedBox(height: 24),
        
        _buildSummaryRow(
          icon: Icons.functions,
          title: 'Todos os gastos',
          count: dados.totalLancamentos,
          value: dados.totalValorGastos,
          percentage: 100.0,
        ),
        const Divider(thickness: 1, color: Colors.black12, height: 20),
        
        ...List.generate(itemCount, (index) {
          final categoriaId = dados.categoriasComGasto[index].key;
          final dadosGasto = dados.gastosPorCategoria[categoriaId];
          final iconesCategorias = _getIconesCategorias(); 
          
          return _buildSummaryRow(
            icon: iconesCategorias[categoriaId] ?? Icons.label_outline,
            title: dados.nomesCategorias[categoriaId] ?? 'Desconhecido',
            count: dadosGasto?.count ?? 0,
            value: dadosGasto?.totalValue ?? 0.0,
            percentage: dados.totalValorGastos > 0 ? ((dadosGasto?.totalValue ?? 0.0) / dados.totalValorGastos) * 100 : 0.0,
          );
        }),

        if (limiteCategorias != null && dados.categoriasComGasto.length > limiteCategorias!)
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GraficoDeGastosScreen())),
              child: Text('Ver mais', style: estiloFonteMonospace.copyWith(color: finBuddyBlue)),
            ),
          ),
      ],
    );
  }

  Widget _buildChartTypeSelector(GraficosViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.pie_chart_outline),
          color: viewModel.tipoSelecionado == TipoGrafico.pizza ? finBuddyBlue : Colors.grey,
          onPressed: () => viewModel.changeChartType(TipoGrafico.pizza),
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart_outlined),
          color: viewModel.tipoSelecionado == TipoGrafico.coluna ? finBuddyBlue : Colors.grey,
          onPressed: () => viewModel.changeChartType(TipoGrafico.coluna),
        ),
        IconButton(
          icon: const Icon(Icons.show_chart_outlined),
          color: viewModel.tipoSelecionado == TipoGrafico.linha ? finBuddyBlue : Colors.grey,
          onPressed: () => viewModel.changeChartType(TipoGrafico.linha),
        ),
      ],
    );
  }

  Widget _buildSelectedChart(GraficosViewModel viewModel, GraficoData dados) {
    final iconesCategorias = _getIconesCategorias();
    switch (viewModel.tipoSelecionado) {
      case TipoGrafico.pizza:
        return construirGraficoPizza(
          dados.categoriasComGasto,
          viewModel.indiceSelecionado,
          (index) => viewModel.onPieSectionTouched(index),
        );
      case TipoGrafico.coluna:
        return construirGraficoColuna(
          dados.categoriasComGasto,
          dados.nomesCategorias,
          iconesCategorias,
        );
      case TipoGrafico.linha:
        final List<FlSpot> gastosExemplo = [
          FlSpot(1, 150), FlSpot(5, 230), FlSpot(10, 200),
          FlSpot(15, 400), FlSpot(20, 350), FlSpot(25, 500),
        ];
        final List<FlSpot> tetoExemplo = [FlSpot(1, 600), FlSpot(30, 600)];
        return construirGraficoLinha(gastosExemplo, tetoExemplo);
    }
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required int count,
    required double value,
    required double percentage,
  }) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: finBuddyDark),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: estiloFonteMonospace),
                Text(
                  '$count lançamentos',
                  style: estiloFonteMonospace.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatadorMoeda.format(value), style: estiloFonteMonospace),
                Text('${percentage.toStringAsFixed(1)}%', style: estiloFonteMonospace.copyWith(fontSize: 12, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, IconData> _getIconesCategorias() {
    return {
      'UEubVETcFQYF8fch2mNE': Icons.medical_services_outlined,
      '7mTuYfsLvMt38WS2YfZ8': Icons.restaurant_outlined,
      'GumHB6ONmWnCZxDe6KJY': Icons.directions_car_outlined,
      'kXP1qi6ae5R8COEaLUB5': Icons.home_outlined,
      'xAVCMGHV3Mb21fj17P5N': Icons.more_horiz,
      '1fGFvMrPLgOaSuzZtvkN': Icons.person_outline,
      'Oio3MSKNhfwTBc9Qw3v5': Icons.phone_android,
    };
  }
}
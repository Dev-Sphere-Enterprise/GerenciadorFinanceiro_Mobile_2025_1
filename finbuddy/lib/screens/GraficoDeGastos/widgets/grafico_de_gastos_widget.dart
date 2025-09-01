import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../shared/core/repositories/categorias_repository.dart';
import '../services/carregar_gastos_por_categoria.dart';
import '../services/categoria_expense_data.dart';
import '../helpers/graficos/construir_grafico_coluna.dart';
import '../helpers/graficos/construir_grafico_pizza.dart';
import '../helpers/graficos/construir_grafico_linha.dart';
import '../grafico_de_gastos_screen.dart';
import '../../../../../shared/constants/style_constants.dart';

enum TipoGrafico { pizza, coluna, linha }

class GraficoData {
  final List<MapEntry<String, double>> categoriasComGasto;
  final Map<String, CategoriaExpenseData> gastosPorCategoria;
  final Map<String, String> nomesCategorias;
  final double totalValorGastos;
  final int totalLancamentos;

  GraficoData({
    required this.categoriasComGasto,
    required this.gastosPorCategoria,
    required this.nomesCategorias,
    required this.totalValorGastos,
    required this.totalLancamentos,
  });
}


class GraficoDeGastosWidget extends StatefulWidget {
  final int? limiteCategorias;
  const GraficoDeGastosWidget({super.key, this.limiteCategorias});

  @override
  State<GraficoDeGastosWidget> createState() => _GraficoDeGastosWidgetState();
}

class _GraficoDeGastosWidgetState extends State<GraficoDeGastosWidget> {
  int _anoSelecionado = DateTime.now().year;
  int _mesSelecionado = DateTime.now().month;
  
  late Future<GraficoData> _dadosDoGraficoFuture;
  
  TipoGrafico _tipoSelecionado = TipoGrafico.coluna;
  int? _indiceSelecionado;

  final Map<String, IconData> _iconesCategorias = {
    'UEubVETcFQYF8fch2mNE': Icons.medical_services_outlined,
    '7mTuYfsLvMt38WS2YfZ8': Icons.restaurant_outlined,
    'GumHB6ONmWnCZxDe6KJY': Icons.directions_car_outlined,
    'kXP1qi6ae5R8COEaLUB5': Icons.home_outlined,
    'xAVCMGHV3Mb21fj17P5N': Icons.more_horiz,
    '1fGFvMrPLgOaSuzZtvkN': Icons.person_outline,
    'Oio3MSKNhfwTBc9Qw3v5': Icons.phone_android,
  };

  @override
  void initState() {
    super.initState();
    _dadosDoGraficoFuture = _carregarDadosDoGrafico();
  }

 Future<GraficoData> _carregarDadosDoGrafico() async {
    final futureGastos = carregarGastosPorCategoria(_anoSelecionado, _mesSelecionado);
    final futureCategorias = StreamZip([getCategoriasGerais(), getCategoriasUsuario()])
        .map((lists) => [...lists[0], ...lists[1]]).first;

    final resultados = await Future.wait([futureGastos, futureCategorias]);

    final gastosPorCategoria = resultados[0] as Map<String, CategoriaExpenseData>;
    final categorias = resultados[1] as List<Map<String, dynamic>>;
    
    final nomesCategorias = <String, String>{for (var c in categorias) c['id']: c['Nome']};
    
    final categoriasComGasto = gastosPorCategoria.entries
        .where((e) => e.value.totalValue > 0 && nomesCategorias.containsKey(e.key))
        .map((e) => MapEntry(e.key, e.value.totalValue))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalValorGastos = gastosPorCategoria.values.fold<double>(0.0, (sum, item) => sum + item.totalValue);
    final totalLancamentos = gastosPorCategoria.values.fold<int>(0, (sum, item) => sum + item.count);

    return GraficoData(
      gastosPorCategoria: gastosPorCategoria,
      nomesCategorias: nomesCategorias,
      categoriasComGasto: categoriasComGasto,
      totalValorGastos: totalValorGastos,
      totalLancamentos: totalLancamentos,
    );
  }

  void _atualizarPeriodo() {
    setState(() {
      _dadosDoGraficoFuture = _carregarDadosDoGrafico();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GraficoData>(
      future: _dadosDoGraficoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Nenhum dado encontrado.', style: estiloFonteMonospace));
        }

        final dados = snapshot.data!;
        return Column(
          children: [
            Text('Gráfico de Gastos', style: estiloFonteMonospace.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildMonthSelector(),
            const SizedBox(height: 16),
            
            if (dados.categoriasComGasto.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Nenhum gasto neste mês.', style: estiloFonteMonospace)))
            else
              _buildChartAndSummary(dados),
          ],
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    const meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(12, (index) {
          final mes = index + 1;
          final selecionado = mes == _mesSelecionado;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () {
                _mesSelecionado = mes;
                _atualizarPeriodo();
              },
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
  
  Widget _buildChartTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.pie_chart_outline),
          color: _tipoSelecionado == TipoGrafico.pizza ? finBuddyBlue : Colors.grey,
          onPressed: () => setState(() => _tipoSelecionado = TipoGrafico.pizza),
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart_outlined),
          color: _tipoSelecionado == TipoGrafico.coluna ? finBuddyBlue : Colors.grey,
          onPressed: () => setState(() => _tipoSelecionado = TipoGrafico.coluna),
        ),
        IconButton(
          icon: const Icon(Icons.show_chart_outlined),
          color: _tipoSelecionado == TipoGrafico.linha ? finBuddyBlue : Colors.grey,
          onPressed: () => setState(() => _tipoSelecionado = TipoGrafico.linha),
        ),
      ],
    );
  }
  
  Widget _buildSelectedChart(GraficoData dados) {
    switch (_tipoSelecionado) {
      case TipoGrafico.pizza:
        return construirGraficoPizza(
          dados.categoriasComGasto,
          _indiceSelecionado,
          (index) => setState(() => _indiceSelecionado = index),
        );
      case TipoGrafico.coluna:
        return construirGraficoColuna(
            dados.categoriasComGasto, dados.nomesCategorias, _iconesCategorias);
      case TipoGrafico.linha:
        final List<FlSpot> gastosExemplo = [
          FlSpot(1, 150), FlSpot(5, 230), FlSpot(10, 200),
          FlSpot(15, 400), FlSpot(20, 350), FlSpot(25, 500),
        ];
        final List<FlSpot> tetoExemplo = [FlSpot(1, 600), FlSpot(30, 600)];
        return construirGraficoLinha(gastosExemplo, tetoExemplo);
    }
  }

  Widget _buildChartAndSummary(GraficoData dados) {
    final itemCount = widget.limiteCategorias != null
        ? (dados.categoriasComGasto.length > widget.limiteCategorias! ? widget.limiteCategorias! : dados.categoriasComGasto.length)
        : dados.categoriasComGasto.length;

    return Column(
      children: [
        _buildChartTypeSelector(),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: _buildSelectedChart(dados)),
        const SizedBox(height: 24),
        
        _buildSummaryRow(
          icon: Icons.functions,
          title: 'Todos os gastos',
          count: dados.totalLancamentos,
          value: dados.totalValorGastos,
          percentage: 100.0,
        ),
        const Divider(thickness: 1),
        
        ...List.generate(itemCount, (index) {
          final categoriaId = dados.categoriasComGasto[index].key;
          final dadosGasto = dados.gastosPorCategoria[categoriaId];
          return _buildSummaryRow(
            icon: _iconesCategorias[categoriaId] ?? Icons.label_outline,
            title: dados.nomesCategorias[categoriaId] ?? 'Desconhecido',
            count: dadosGasto?.count ?? 0,
            value: dadosGasto?.totalValue ?? 0.0,
            percentage: dados.totalValorGastos > 0 ? ((dadosGasto?.totalValue ?? 0.0) / dados.totalValorGastos) * 100 : 0.0,
          );
        }),

        if (widget.limiteCategorias != null && dados.categoriasComGasto.length > widget.limiteCategorias!)
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GraficoDeGastosScreen())),
              child: Text('Ver mais', style: estiloFonteMonospace.copyWith(color: finBuddyBlue)),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required int count,
    required double value,
    required double percentage,
  }) {
    final formatadorMoeda =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
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
                  style: estiloFonteMonospace.copyWith(
                      fontSize: 12, fontWeight: FontWeight.normal),
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
                Text(formatadorMoeda.format(value),
                    style: estiloFonteMonospace),
                Text('${percentage.toStringAsFixed(1)}%',
                    style: estiloFonteMonospace.copyWith(
                        fontSize: 12, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
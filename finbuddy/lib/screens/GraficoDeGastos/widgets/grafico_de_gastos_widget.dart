import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';
import 'package:intl/intl.dart';
import '../../Categorias/helpers/get_categorias_gerais.dart';
import '../../Categorias/helpers/get_categorias_usuario.dart';
import '../services/carregar_gastos_por_categoria.dart';
import '../services/categoria_expense_data.dart';
import '../helpers/graficos/construir_grafico_coluna.dart';
import '../grafico_de_gastos_screen.dart';

// --- Constantes de Estilo ---
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);
// ----------------------------

class GraficoDeGastosWidget extends StatefulWidget {
  final int? limiteCategorias;

  const GraficoDeGastosWidget({super.key, this.limiteCategorias});

  @override
  State<GraficoDeGastosWidget> createState() => _GraficoDeGastosWidgetState();
}

class _GraficoDeGastosWidgetState extends State<GraficoDeGastosWidget> {
  int _anoSelecionado = DateTime.now().year;
  int _mesSelecionado = DateTime.now().month;
  
  Map<String, CategoriaExpenseData> _gastosPorCategoria = {};
  Map<String, String> _nomesCategorias = {};

  final Map<String, IconData> _iconesCategorias = {
    'saude': Icons.medical_services_outlined,
    'alimentacao': Icons.restaurant_outlined,
    'transporte': Icons.directions_car_outlined,
    'casa': Icons.home_outlined,
    'outros': Icons.more_horiz,
    'despesas_pessoais': Icons.person_outline,
    'comunicacao': Icons.phone_android,
  };

  @override
  void initState() {
    super.initState();
    _carregarGastos();
  }

  Future<void> _carregarGastos() async {
    final gastos = await carregarGastosPorCategoria(_anoSelecionado, _mesSelecionado);
    if (mounted) {
      setState(() => _gastosPorCategoria = gastos);
    }
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
                setState(() => _mesSelecionado = mes);
                _carregarGastos();
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
                Text('$count lançamentos', style: estiloFonteMonospace.copyWith(fontSize: 12, fontWeight: FontWeight.normal)),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: StreamZip([getCategoriasGerais(), getCategoriasUsuario()]).map((lists) => [...lists[0], ...lists[1]]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _nomesCategorias.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          _nomesCategorias = {for (var c in snapshot.data!) c['id']: c['Nome']};
        }

        final categoriasComGasto = _gastosPorCategoria.entries
            .where((e) => e.value.totalValue > 0 && _nomesCategorias.containsKey(e.key))
            .map((e) => MapEntry(e.key, e.value.totalValue))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final totalValorGastos = _gastosPorCategoria.values.fold<double>(0.0, (sum, item) => sum + item.totalValue);
        final totalLancamentos = _gastosPorCategoria.values.fold<int>(0, (sum, item) => sum + item.count);

        final itemCount = widget.limiteCategorias != null
            ? (categoriasComGasto.length > widget.limiteCategorias! ? widget.limiteCategorias! : categoriasComGasto.length)
            : categoriasComGasto.length;

        return Column(
          children: [
            Text('Gráfico de Gastos', style: estiloFonteMonospace.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildMonthSelector(),
            const SizedBox(height: 24),
            
            if (categoriasComGasto.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Nenhum gasto neste mês.', style: estiloFonteMonospace)))
            else ...[
              SizedBox(
                height: 200,
                child: construirGraficoColuna(categoriasComGasto, _nomesCategorias, _iconesCategorias),
              ),
              const SizedBox(height: 24),
              
              _buildSummaryRow(
                icon: Icons.functions,
                title: 'Todos os gastos',
                count: totalLancamentos,
                value: totalValorGastos,
                percentage: 100.0,
              ),
              const Divider(thickness: 1),
              
              ...List.generate(itemCount, (index) {
                final categoriaId = categoriasComGasto[index].key;
                final dadosGasto = _gastosPorCategoria[categoriaId];
                
                return _buildSummaryRow(
                  icon: _iconesCategorias[categoriaId] ?? Icons.label_outline,
                  title: _nomesCategorias[categoriaId] ?? 'Desconhecido',
                  count: dadosGasto?.count ?? 0,
                  value: dadosGasto?.totalValue ?? 0.0,
                  percentage: totalValorGastos > 0 ? ((dadosGasto?.totalValue ?? 0.0) / totalValorGastos) * 100 : 0.0,
                );
              }),

              if (widget.limiteCategorias != null && categoriasComGasto.length > widget.limiteCategorias!)
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GraficoDeGastosScreen()));
                    },
                    child: Text('Ver mais', style: estiloFonteMonospace.copyWith(color: finBuddyBlue)),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
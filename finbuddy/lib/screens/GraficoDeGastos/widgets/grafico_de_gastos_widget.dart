import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';
import '../../Categorias/helpers/get_categorias_gerais.dart';
import '../../Categorias/helpers/get_categorias_usuario.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/carregar_gastos_por_categoria.dart';
import '../services/categoria_expense_data.dart';
import '../helpers/graficos/construir_grafico_pizza.dart';
import '../helpers/graficos/construir_grafico_coluna.dart';
import '../helpers/graficos/construir_grafico_linha.dart';
import '../helpers/periodo/gerar_anos.dart';
import '../grafico_de_gastos_screen.dart';

enum TipoGrafico { pizza, coluna, linha }

class GraficoDeGastosWidget extends StatefulWidget {
  final int? limiteCategorias;

  const GraficoDeGastosWidget({super.key, this.limiteCategorias});

  @override
  State<GraficoDeGastosWidget> createState() => _GraficoDeGastosWidgetState();
}

class _GraficoDeGastosWidgetState extends State<GraficoDeGastosWidget> {
  int _anoSelecionado = DateTime.now().year;
  int _mesSelecionado = DateTime.now().month;
  late ScrollController _scrollController;
  late List<GlobalKey> _mesKeys;

  Map<String, CategoriaExpenseData> _gastosPorCategoria = {};
  Map<String, String> _nomesCategorias = {};
  int? _indiceSelecionado;
  TipoGrafico _tipoSelecionado = TipoGrafico.pizza;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _mesKeys = List.generate(12, (_) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyParaMesAtual = _mesKeys[_mesSelecionado - 1];
      if (keyParaMesAtual.currentContext != null) {
        final renderBox =
            keyParaMesAtual.currentContext!.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero).dx - 16;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _carregarGastos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _carregarGastos() async {
    final gastos = await carregarGastosPorCategoria(
      _anoSelecionado,
      _mesSelecionado,
    );
    setState(() {
      _gastosPorCategoria = gastos;
    });
  }

  void _atualizarIndiceSelecionado(int? novoIndice) {
    setState(() {
      _indiceSelecionado = novoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: StreamZip([
        getCategoriasGerais(),
        getCategoriasUsuario(),
      ]).map((lists) => [...lists[0], ...lists[1]]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma categoria disponível.'));
        }

        final categorias = snapshot.data!;
        _nomesCategorias = {for (var c in categorias) c['id']: c['Nome']};

        final categoriasComGasto = _gastosPorCategoria.entries
            .where(
              (e) => e.value.count > 0 && _nomesCategorias.containsKey(e.key),
            )
            .map((e) => MapEntry(e.key, e.value.count))
            .toList();

        final totalGastos = _gastosPorCategoria.values.fold<int>(
          0,
          (sum, item) => sum + item.count,
        );

        final itemCount = widget.limiteCategorias != null
            ? (categorias.length > widget.limiteCategorias!
                  ? widget.limiteCategorias!
                  : categorias.length)
            : categorias.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      children: List.generate(12, (index) {
                        final mes = index + 1;
                        final nomeMes = [
                          'Jan',
                          'Fev',
                          'Mar',
                          'Abr',
                          'Mai',
                          'Jun',
                          'Jul',
                          'Ago',
                          'Set',
                          'Out',
                          'Nov',
                          'Dez',
                        ][index];
                        final selecionado = mes == _mesSelecionado;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            key: _mesKeys[index],
                            label: Text(nomeMes),
                            selected: selecionado,
                            onSelected: (bool selected) {
                              setState(() {
                                _mesSelecionado = mes;
                              });
                              _carregarGastos();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final keyParaMesSelecionado = _mesKeys[mes - 1];
                                if (keyParaMesSelecionado.currentContext !=
                                    null) {
                                  final renderBox =
                                      keyParaMesSelecionado.currentContext!
                                              .findRenderObject()
                                          as RenderBox;
                                  final offset = renderBox
                                      .localToGlobal(Offset.zero)
                                      .dx;
                                  _scrollController.animateTo(
                                    offset - 16,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Ano: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<int>(
                        value: _anoSelecionado,
                        items: gerarAnos().map((ano) {
                          return DropdownMenuItem(
                            value: ano,
                            child: Text('$ano'),
                          );
                        }).toList(),
                        onChanged: (novoAno) {
                          setState(() {
                            _anoSelecionado = novoAno!;
                          });
                          _carregarGastos();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (categoriasComGasto.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('Nenhum gasto registrado este mês.'),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Tipo de Gráfico:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.pie_chart),
                              color: _tipoSelecionado == TipoGrafico.pizza
                                  ? Colors.blueGrey
                                  : Colors.grey,
                              onPressed: () {
                                setState(
                                  () => _tipoSelecionado = TipoGrafico.pizza,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bar_chart),
                              color: _tipoSelecionado == TipoGrafico.coluna
                                  ? Colors.blueGrey
                                  : Colors.grey,
                              onPressed: () {
                                setState(
                                  () => _tipoSelecionado = TipoGrafico.coluna,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.show_chart),
                              color: _tipoSelecionado == TipoGrafico.linha
                                  ? Colors.blueGrey
                                  : Colors.grey,
                              onPressed: () {
                                setState(
                                  () => _tipoSelecionado = TipoGrafico.linha,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 250,
                          child: _tipoSelecionado == TipoGrafico.pizza
                              ? construirGraficoPizza(
                                  categoriasComGasto,
                                  _indiceSelecionado,
                                  _atualizarIndiceSelecionado,
                                )
                              : _tipoSelecionado == TipoGrafico.coluna
                                  ? construirGraficoColuna(
                                      categoriasComGasto,
                                      _nomesCategorias,
                                    )
                                  : construirGraficoLinha(
                                      categoriasComGasto,
                                      _nomesCategorias,
                                    ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: List.generate(categoriasComGasto.length, (
                            index,
                          ) {
                            final categoriaId = categoriasComGasto[index].key;
                            final nome = _nomesCategorias[categoriaId]!;
                            final cor = Colors
                                .primaries[index % Colors.primaries.length];
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 14, height: 14, color: cor),
                                const SizedBox(width: 6),
                                Text(nome),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                final id = categoria['id'];
                final nome = categoria['Nome'];
                final dadosGasto = _gastosPorCategoria[id];
                final contagem = dadosGasto?.count ?? 0;
                final valorTotal = dadosGasto?.totalValue ?? 0.0;
                final porcentagem = totalGastos > 0
                    ? (contagem / totalGastos) * 100
                    : 0.0;

                return ListTile(
                  title: Row(
                    children: [
                      Text(nome),
                      const Spacer(),
                      Text('R\$ ${valorTotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text('Gastos: $contagem'),
                      const Spacer(),
                      Text('${porcentagem.toStringAsFixed(1)}%'),
                    ],
                  ),
                );
              },
            ),
            if (widget.limiteCategorias != null &&
                categorias.length > widget.limiteCategorias!)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GraficoDeGastosScreen(),
                        ),
                      );
                    },
                    child: const Text('Ver mais'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

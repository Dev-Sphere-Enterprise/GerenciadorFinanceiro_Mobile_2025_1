import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';

class GastosFixosScreen extends StatefulWidget {
  const GastosFixosScreen({super.key});

  @override
  State<GastosFixosScreen> createState() => _GastosFixosScreenState();
}

class _GastosFixosScreenState extends State<GastosFixosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Obter categorias (padrões + usuário)
  Stream<List<Map<String, dynamic>>> _getCategorias() {
    final categoriasGerais = _firestore
        .collection('categorias_gerais')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {'id': doc.id, 'nome': doc['nome'], 'isGeneral': true},
              )
              .toList(),
        );

    final categoriasUsuario = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('categorias')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'nome': doc['Nome'],
                  'isGeneral': false,
                },
              )
              .toList(),
        );

    return StreamZip([
      categoriasGerais,
      categoriasUsuario,
    ]).map((lists) => [...lists[0], ...lists[1]]);
  }

  /// Obter tipos de pagamento (padrões + usuário)
  Stream<List<Map<String, dynamic>>> _getTiposPagamento() {
    final tiposGerais = _firestore
        .collection('tipo_pagamentos_gerais')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'nome': doc['nome'],
                  'isGeneral': true,
                  'Parcelavel': doc['Parcelavel'] ?? false,
                  'UsaCartao': doc['UsaCartao'] ?? false,
                },
              )
              .toList(),
        );

    final tiposUsuario = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tipos_pagamentos')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'nome': doc['Nome'],
                  'isGeneral': false,
                  'Parcelavel': doc['Parcelavel'] ?? false,
                  'UsaCartao': doc['UsaCartao'] ?? false,
                },
              )
              .toList(),
        );

    return StreamZip([
      tiposGerais,
      tiposUsuario,
    ]).map((lists) => [...lists[0], ...lists[1]]);
  }

  /// Obter cartões do usuário
  Stream<List<Map<String, dynamic>>> _getCartoes() {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cartoes')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, 'nome': doc['Nome'] ?? ''})
              .toList(),
        );
  }

  /// Adicionar ou Editar um gasto fixo
  Future<void> _addOrEditGasto({
    String? id,
    String? nome,
    double? valor,
    String? tipoPagamentoId,
    String? cartaoId,
    String? categoriaId,
    int parcelas = 1,
    DateTime? dataCompra,
  }) async {
    final nomeController = TextEditingController(text: nome ?? '');
    final valorController = TextEditingController(
      text: valor?.toString() ?? '',
    );
    DateTime selectedDate = dataCompra ?? DateTime.now();

    String? selectedTipoPagamento = tipoPagamentoId;
    String? selectedCartao = cartaoId;
    String? selectedCategoria = categoriaId;
    int selectedParcelas = parcelas;

    final tiposSnapshot = await _getTiposPagamento().first;
    final categoriasSnapshot = await _getCategorias().first;
    final cartoesSnapshot = await _getCartoes().first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isParcelavel = false;
            bool exigeCartao = false;

            if (selectedTipoPagamento != null) {
              final tipoSelecionado = tiposSnapshot.firstWhere(
                (tipo) => tipo['id'] == selectedTipoPagamento,
                orElse: () => {},
              );

              isParcelavel = tipoSelecionado['Parcelavel'] == true;
              exigeCartao = tipoSelecionado['UsaCartao'] == true;
            }

            return AlertDialog(
              title: Text(
                id == null ? 'Adicionar Gasto Fixo' : 'Editar Gasto Fixo',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Gasto',
                      ),
                    ),
                    TextField(
                      controller: valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedTipoPagamento,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Pagamento',
                      ),
                      items: tiposSnapshot
                          .map(
                            (tipo) => DropdownMenuItem<String>(
                              value: tipo['id'],
                              child: Text(
                                tipo['nome'] ?? tipo['Nome'] ?? 'Sem nome',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedTipoPagamento = value;

                          final tipoSelecionado = tiposSnapshot.firstWhere(
                            (tipo) => tipo['id'] == selectedTipoPagamento,
                            orElse: () => {},
                          );

                          isParcelavel = tipoSelecionado['Parcelavel'] == true;
                          exigeCartao = tipoSelecionado['UsaCartao'] == true;
                        });
                      },
                    ),
                    if (isParcelavel)
                      DropdownButtonFormField<int>(
                        value: selectedParcelas,
                        decoration: const InputDecoration(
                          labelText: 'Parcelas',
                        ),
                        items: List.generate(24, (i) => i + 1)
                            .map(
                              (num) => DropdownMenuItem(
                                value: num,
                                child: Text('$num x'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedParcelas = value ?? 1;
                          });
                        },
                      ),
                    if (exigeCartao)
                      DropdownButtonFormField<String>(
                        value: selectedCartao,
                        decoration: const InputDecoration(labelText: 'Cartão'),
                        items: cartoesSnapshot
                            .map(
                              (cartao) => DropdownMenuItem<String>(
                                value: cartao['id'],
                                child: Text(
                                  cartao['nome'] ??
                                      cartao['Nome'] ??
                                      'Sem nome',
                                ),
                              ),
                            )
                            .toList(),

                        onChanged: (value) {
                          setModalState(() {
                            selectedCartao = value;
                          });
                        },
                      ),
                    DropdownButtonFormField<String>(
                      value: selectedCategoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: categoriasSnapshot
                          .map(
                            (cat) => DropdownMenuItem<String>(
                              value: cat['id'],
                              child: Text(
                                cat['nome'] ?? cat['Nome'] ?? 'Sem nome',
                              ),
                            ),
                          )
                          .toList(),

                      onChanged: (value) {
                        setModalState(() {
                          selectedCategoria = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(1925),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        "Selecionar Data da Compra: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.trim().isEmpty ||
                        valorController.text.trim().isEmpty ||
                        selectedTipoPagamento == null ||
                        selectedCategoria == null) {
                      return;
                    }

                    final valor =
                        double.tryParse(valorController.text.trim()) ?? 0.0;

                    // Se exige cartão, verifica o crédito
                    if (selectedCartao != null && exigeCartao) {
                      final cartaoRef = _firestore
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('cartoes')
                          .doc(selectedCartao);

                      final snapshot = await cartaoRef.get();
                      final cartaoData = snapshot.data();

                      if (cartaoData != null) {
                        final creditoDisponivel =
                            (cartaoData['Credito_Disponivel'] ?? 0.0) as double;

                        // Verificação: valor total não pode ultrapassar o crédito
                        if (valor > creditoDisponivel) {
                          Navigator.pop(context); // fecha o dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'O cartão selecionado não possui crédito suficiente para este gasto.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }
                    }

                    final gastoMap = {
                      'Nome': nomeController.text.trim(),
                      'Valor': valor,
                      'ID_Tipo_Pagamento': selectedTipoPagamento,
                      'ID_Cartao': selectedCartao,
                      'ID_Categoria': selectedCategoria,
                      'Parcelas': isParcelavel ? selectedParcelas : 1,
                      'Data_Compra': Timestamp.fromDate(selectedDate),
                      'Recorrencia': true,
                      'Deletado': false,
                      'Data_Atualizacao': Timestamp.now(),
                    };

                    final gastosRef = _firestore
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('gastos_fixos');

                    if (id == null) {
                      gastoMap['Data_Criacao'] = Timestamp.now();
                      await gastosRef.add(gastoMap);
                    } else {
                      await gastosRef.doc(id).update(gastoMap);
                    }

                    // Atualizar fatura e crédito
                    if (selectedCartao != null && exigeCartao) {
                      final cartaoRef = _firestore
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('cartoes')
                          .doc(selectedCartao);

                      final snapshot = await cartaoRef.get();
                      final cartaoData = snapshot.data()!;

                      final valorParcela = valor / selectedParcelas;
                      final novaFatura =
                          (cartaoData['Valor_Fatura_Atual'] ?? 0.0) +
                          valorParcela;
                      final novoCredito =
                          (cartaoData['Credito_Disponivel'] ?? 0.0) - valor;

                      await cartaoRef.update({
                        'Valor_Fatura_Atual': novaFatura,
                        'Credito_Disponivel': novoCredito,
                        'Data_Atualizacao': Timestamp.now(),
                      });

                      for (int i = 1; i < selectedParcelas; i++) {
                        final proximaData = DateTime(
                          selectedDate.year,
                          selectedDate.month + i,
                          selectedDate.day,
                        );

                        await _firestore
                            .collection('users')
                            .doc(currentUser!.uid)
                            .collection('parcelas_agendadas')
                            .add({
                              'ID_Cartao': selectedCartao,
                              'Valor_Parcela': valorParcela,
                              'Data': Timestamp.fromDate(proximaData),
                              'Processado': false,
                              'ID_Gasto_Original': gastoMap['id'], // opcional
                            });
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteGasto(String id) async {
    final gastosRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('gastos_fixos');

    await gastosRef.doc(id).update({
      'Deletado': true,
      'Data_Atualizacao': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Fixos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('gastos_fixos')
            .where('Deletado', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum gasto fixo cadastrado.'));
          }

          final gastos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              final id = gasto.id;
              final nome = gasto['Nome'] ?? '';
              final valor = gasto['Valor'] ?? 0.0;
              final dataCompra = (gasto['Data_Compra'] as Timestamp).toDate();
              final parcelas = gasto['Parcelas'] ?? 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Valor: R\$${valor.toStringAsFixed(2)}\nData: ${DateFormat('dd/MM/yyyy').format(dataCompra)}\nParcelas: $parcelas',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditGasto(
                          id: id,
                          nome: nome,
                          valor: valor.toDouble(),
                          dataCompra: dataCompra,
                          parcelas: parcelas,
                          tipoPagamentoId: gasto['ID_Tipo_Pagamento'],
                          cartaoId: gasto['ID_Cartao'],
                          categoriaId: gasto['ID_Categoria'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGasto(id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditGasto(),
        label: const Text('Adicionar Gasto'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

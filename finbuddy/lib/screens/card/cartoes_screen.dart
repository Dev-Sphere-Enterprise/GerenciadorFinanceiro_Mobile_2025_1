import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartoesScreen extends StatefulWidget {
  const CartoesScreen({super.key});

  @override
  State<CartoesScreen> createState() => _CartoesScreenState();
}

class _CartoesScreenState extends State<CartoesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Adicionar ou Editar Cartão
  Future<void> _addOrEditCartao({
    String? id,
    String? nome,
    double? valorFatura,
    double? limiteCredito,
    // ignore: unused_element_parameter
    double? creditoDisponivel,
    DateTime? dataFechamento,
    DateTime? dataVencimento,
  }) async {
    final nomeController = TextEditingController(text: nome ?? '');
    final valorFaturaController = TextEditingController(text: valorFatura?.toString() ?? '');
    final limiteController = TextEditingController(text: limiteCredito?.toString() ?? '');

    DateTime selectedFechamento = dataFechamento ?? DateTime.now();
    DateTime selectedVencimento = dataVencimento ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(id == null ? 'Adicionar Cartão' : 'Editar Cartão'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome do Cartão'),
                  ),
                  TextField(
                    controller: valorFaturaController,
                    decoration: const InputDecoration(labelText: 'Valor Fatura Atual (R\$)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: limiteController,
                    decoration: const InputDecoration(labelText: 'Limite de Crédito (R\$)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedFechamento,
                        firstDate: DateTime(1925),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => selectedFechamento = picked);
                      }
                    },
                    child: Text("Data Fechamento: ${DateFormat('dd/MM/yyyy').format(selectedFechamento)}"),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedVencimento,
                        firstDate: DateTime(1925),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => selectedVencimento = picked);
                      }
                    },
                    child: Text("Data Vencimento: ${DateFormat('dd/MM/yyyy').format(selectedVencimento)}"),
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
                      valorFaturaController.text.trim().isEmpty ||
                      limiteController.text.trim().isEmpty) {
                    return;
                  }

                  final valorFatura = double.tryParse(valorFaturaController.text.trim()) ?? 0.0;
                  final limite = double.tryParse(limiteController.text.trim()) ?? 0.0;

                  final dataMap = {
                    'Nome': nomeController.text.trim(),
                    'Valor_Fatura_Atual': valorFatura,
                    'Limite_Credito': limite,
                    'Credito_Disponivel': limite - valorFatura,
                    'Data_Fechamento': Timestamp.fromDate(selectedFechamento),
                    'Data_Vencimento': Timestamp.fromDate(selectedVencimento),
                    'Deletado': false,
                    'Data_Atualizacao': Timestamp.now(),
                  };

                  final cartoesRef = _firestore
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('cartoes');

                  if (id == null) {
                    dataMap['Data_Criacao'] = Timestamp.now();
                    await cartoesRef.add(dataMap);
                  } else {
                    await cartoesRef.doc(id).update(dataMap);
                  }

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

  /// Marcar como deletado
  Future<void> _deleteCartao(String id) async {
    final cartoesRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cartoes');

    await cartoesRef.doc(id).update({
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
        title: const Text('Meus Cartões'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('cartoes')
            .where('Deletado', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum cartão cadastrado.'));
          }

          final cartoes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartoes.length,
            itemBuilder: (context, index) {
              final cartao = cartoes[index];
              final id = cartao.id;
              final nome = cartao['Nome'] ?? '';
              final valorFatura = cartao['Valor_Fatura_Atual'] ?? 0.0;
              final limite = cartao['Limite_Credito'] ?? 0.0;

              final dataFechamento = cartao['Data_Fechamento'] != null
                  ? (cartao['Data_Fechamento'] as Timestamp).toDate()
                  : null;

              final dataVencimento = cartao['Data_Vencimento'] != null
                  ? (cartao['Data_Vencimento'] as Timestamp).toDate()
                  : null;
              final creditoDisponivel = cartao['Credito_Disponivel'] ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Fatura: R\$${valorFatura.toStringAsFixed(2)} \nCrédito Total: R\$${limite.toStringAsFixed(2)}'
                        '\nCrédito Disponível: R\$${creditoDisponivel.toStringAsFixed(2)}'
                        '\nFechamento: ${dataFechamento != null ? DateFormat('dd/MM').format(dataFechamento) : '-'}'
                        '\nVencimento: ${dataVencimento != null ? DateFormat('dd/MM').format(dataVencimento) : '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditCartao(
                          id: id,
                          nome: nome,
                          valorFatura: valorFatura.toDouble(),
                          limiteCredito: limite.toDouble(),
                          dataFechamento: dataFechamento ?? DateTime.now(),
                          dataVencimento: dataVencimento ?? DateTime.now(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCartao(id),
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
        onPressed: () => _addOrEditCartao(),
        label: const Text('Adicionar Cartão'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

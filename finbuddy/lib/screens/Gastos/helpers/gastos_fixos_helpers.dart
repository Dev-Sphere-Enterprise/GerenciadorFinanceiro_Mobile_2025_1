import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '/../services/firestore_helpers.dart';

Future<void> showAddOrEditGastoDialog({
  required BuildContext context,
  String? gastoId,
  String? nome,
  double? valor,
  DateTime? dataCompra,
  int parcelas = 1,
  String? tipoPagamentoId,
  String? cartaoId,
  String? categoriaId,
}) async {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final currentUser = _auth.currentUser;

  final nomeController = TextEditingController(text: nome ?? '');
  final valorController = TextEditingController(text: valor?.toString() ?? '');
  DateTime selectedDate = dataCompra ?? DateTime.now();

  String? selectedTipo = tipoPagamentoId;
  String? selectedCartao = cartaoId;
  String? selectedCategoria = categoriaId;
  int selectedParcelas = parcelas;

  final tiposSnapshot = await FirestoreHelpers.getTiposPagamento().first;
  final categoriasSnapshot = await FirestoreHelpers.getCategorias().first;
  final cartoesSnapshot = await FirestoreHelpers.getCartoes().first;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        bool isParcelavel = false;
        bool exigeCartao = false;

        if (selectedTipo != null) {
          final tipo = tiposSnapshot.firstWhere((t) => t['id'] == selectedTipo, orElse: () => {});
          isParcelavel = tipo['Parcelavel'] == true;
          exigeCartao = tipo['UsaCartao'] == true;
        }

        return AlertDialog(
          title: Text(gastoId == null ? 'Adicionar Gasto' : 'Editar Gasto'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do Gasto'),
                ),
                TextField(
                  controller: valorController,
                  decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedTipo,
                  decoration: const InputDecoration(labelText: 'Tipo de Pagamento'),
                  items: tiposSnapshot.map<DropdownMenuItem<String>>((tipo) {
                    return DropdownMenuItem(
                      value: tipo['id'],
                      child: Text(tipo['nome'] ?? tipo['Nome'] ?? 'Sem nome'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedTipo = value;
                      final tipo = tiposSnapshot.firstWhere((t) => t['id'] == value, orElse: () => {});
                      isParcelavel = tipo['Parcelavel'] == true;
                      exigeCartao = tipo['UsaCartao'] == true;
                    });
                  },
                ),
                if (isParcelavel)
                  DropdownButtonFormField<int>(
                    value: selectedParcelas,
                    decoration: const InputDecoration(labelText: 'Parcelas'),
                    items: List.generate(24, (i) => i + 1)
                        .map((p) => DropdownMenuItem(value: p, child: Text('$p x')))
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
                    items: cartoesSnapshot.map<DropdownMenuItem<String>>((cartao) {
                      return DropdownMenuItem(
                        value: cartao['id'],
                        child: Text(cartao['nome'] ?? cartao['Nome'] ?? 'Sem nome'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCartao = value;
                      });
                    },
                  ),
                DropdownButtonFormField<String>(
                  value: selectedCategoria,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: categoriasSnapshot.map<DropdownMenuItem<String>>((cat) {
                    return DropdownMenuItem(
                      value: cat['id'],
                      child: Text(cat['nome'] ?? cat['Nome'] ?? 'Sem nome'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedCategoria = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1925),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setModalState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text('Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () async {
                final valorFinal = double.tryParse(valorController.text) ?? 0.0;
                final gastoMap = {
                  'Nome': nomeController.text.trim(),
                  'Valor': valorFinal,
                  'ID_Tipo_Pagamento': selectedTipo,
                  'ID_Cartao': selectedCartao,
                  'ID_Categoria': selectedCategoria,
                  'Parcelas': isParcelavel ? selectedParcelas : 1,
                  'Data_Compra': Timestamp.fromDate(selectedDate),
                  'Recorrencia': true,
                  'Deletado': false,
                  'Data_Atualizacao': Timestamp.now(),
                };

                final ref = _firestore
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('gastos_fixos');

                if (gastoId == null) {
                  gastoMap['Data_Criacao'] = Timestamp.now();
                  await ref.add(gastoMap);
                } else {
                  await ref.doc(gastoId).update(gastoMap);
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    },
  );
}

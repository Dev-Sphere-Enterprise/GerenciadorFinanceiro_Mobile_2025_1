import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> showAddEditCartaoDialog({
  required BuildContext context,
  String? id,
  String? nome,
  double? valorFatura,
  double? limiteCredito,
  DateTime? dataFechamento,
  DateTime? dataVencimento,
}) async {
  final nomeController = TextEditingController(text: nome ?? '');
  final valorFaturaController = TextEditingController(text: valorFatura?.toString() ?? '');
  final limiteController = TextEditingController(text: limiteCredito?.toString() ?? '');

  DateTime selectedFechamento = dataFechamento ?? DateTime.now();
  DateTime selectedVencimento = dataVencimento ?? DateTime.now();

  final currentUser = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  if (currentUser == null) return;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                      limiteController.text.trim().isEmpty) return;

                  final valor = double.tryParse(valorFaturaController.text.trim()) ?? 0.0;
                  final limite = double.tryParse(limiteController.text.trim()) ?? 0.0;

                  final dataMap = {
                    'Nome': nomeController.text.trim(),
                    'Valor_Fatura_Atual': valor,
                    'Limite_Credito': limite,
                    'Credito_Disponivel': limite - valor,
                    'Data_Fechamento': Timestamp.fromDate(selectedFechamento),
                    'Data_Vencimento': Timestamp.fromDate(selectedVencimento),
                    'Deletado': false,
                    'Data_Atualizacao': Timestamp.now(),
                  };

                  final cartoesRef = firestore
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('cartoes');

                  if (id == null) {
                    dataMap['Data_Criacao'] = Timestamp.now();
                    await cartoesRef.add(dataMap);
                  } else {
                    await cartoesRef.doc(id).update(dataMap);
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

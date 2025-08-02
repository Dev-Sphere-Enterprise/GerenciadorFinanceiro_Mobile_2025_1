import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showAddOrEditAporteDialog({
  required BuildContext context,
  required FirebaseFirestore firestore,
  required User currentUser,
  required String metaId,
  required Future<void> Function() atualizarValorMeta,

  String? id,
  double? valor,
  DateTime? data,
}) async {
  final valorController = TextEditingController(text: valor?.toString() ?? '');
  DateTime selectedDate = data ?? DateTime.now();

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return AlertDialog(
          title: Text(id == null ? 'Adicionar Aporte' : 'Editar Aporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valorController,
                decoration: const InputDecoration(labelText: 'Valor do Aporte'),
                keyboardType: TextInputType.number,
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: Text("Selecionar Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final valor = double.tryParse(valorController.text.trim()) ?? 0.0;
                final dataMap = {
                  'Valor': valor,
                  'Data_Aporte': Timestamp.fromDate(selectedDate),
                  'Deletado': false,
                  'Data_Atualizacao': Timestamp.now(),
                };

                final ref = firestore
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('metas')
                    .doc(metaId)
                    .collection('aportes_meta');

                if (id == null) {
                  dataMap['Data_Criacao'] = Timestamp.now();
                  await ref.add(dataMap);
                } else {
                  await ref.doc(id).update(dataMap);
                }

                await atualizarValorMeta();
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            )
          ],
        );
      },
    ),
  );
}

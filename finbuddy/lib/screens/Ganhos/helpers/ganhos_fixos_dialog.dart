import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showAddOrEditGanhoDialog({
  required BuildContext context,
  String? id,
  String? nome,
  double? valor,
  DateTime? data,
  required User currentUser,
  required FirebaseFirestore firestore,
}) async {
  final nomeController = TextEditingController(text: nome ?? '');
  final valorController = TextEditingController(text: valor?.toString() ?? '');
  DateTime selectedDate = data ?? DateTime.now();

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        return AlertDialog(
          title: Text(id == null ? 'Adicionar Ganho' : 'Editar Ganho'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Ganho'),
              ),
              TextField(
                controller: valorController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
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
                child: Text("Selecionar Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isEmpty || valorController.text.trim().isEmpty) return;

                final valor = double.tryParse(valorController.text.trim()) ?? 0.0;
                final dataMap = {
                  'Nome': nomeController.text.trim(),
                  'Valor': valor,
                  'Data_Recebimento': Timestamp.fromDate(selectedDate),
                  'Recorrencia': true,
                  'Deletado': false,
                  'Data_Atualizacao': Timestamp.now(),
                };

                final ganhosRef = firestore
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('ganhos_fixos');

                if (id == null) {
                  dataMap['Data_Criacao'] = Timestamp.now();
                  await ganhosRef.add(dataMap);
                } else {
                  await ganhosRef.doc(id).update(dataMap);
                }

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

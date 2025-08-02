// lib/dialogs/add_gain_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_service.dart';

Future<void> showAddGainDialog(BuildContext context) async {
  final nomeController = TextEditingController();
  final valorController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final TransactionService transactionService = TransactionService();

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        return AlertDialog(
          title: const Text('Adicionar Ganho Pontual'),
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

                final double valor = double.tryParse(valorController.text.trim()) ?? 0.0;

                await transactionService.addGanhoPontual(
                  nome: nomeController.text.trim(),
                  valor: valor,
                  dataRecebimento: selectedDate,
                );

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
// lib/dialogs/add_expense_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_service.dart';
import '/../services/firestore_helpers.dart';

Future<void> showAddExpenseDialog(BuildContext context) async {
  final nomeController = TextEditingController();
  final valorController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  String? selectedTipoPagamento;
  String? selectedCartao;
  String? selectedCategoria;
  int selectedParcelas = 1;

  final tiposSnapshot = await FirestoreHelpers.getTiposPagamento().first;
  final categoriasSnapshot = await FirestoreHelpers.getCategorias().first;
  final cartoesSnapshot = await FirestoreHelpers.getCartoes().first;
  final TransactionService transactionService = TransactionService();

  return showDialog(
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
            title: const Text('Adicionar Gasto Pontual'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    value: selectedTipoPagamento,
                    decoration: const InputDecoration(labelText: 'Tipo de Pagamento'),
                    items: tiposSnapshot.map((tipo) => DropdownMenuItem<String>(
                      value: tipo['id'],
                      child: Text(tipo['nome'] ?? tipo['Nome'] ?? 'Sem nome'),
                    )).toList(),
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
                      decoration: const InputDecoration(labelText: 'Parcelas'),
                      items: List.generate(24, (i) => i + 1)
                          .map((num) => DropdownMenuItem(
                        value: num,
                        child: Text('$num x'),
                      ))
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
                      items: cartoesSnapshot.map((cartao) => DropdownMenuItem<String>(
                        value: cartao['id'],
                        child: Text(cartao['nome'] ?? cartao['Nome'] ?? 'Sem nome'),
                      )).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCartao = value;
                        });
                      },
                    ),
                  DropdownButtonFormField<String>(
                    value: selectedCategoria,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: categoriasSnapshot.map((cat) => DropdownMenuItem<String>(
                      value: cat['id'],
                      child: Text(cat['nome'] ?? cat['Nome'] ?? 'Sem nome'),
                    )).toList(),
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
                    child: Text("Selecionar Data da Compra: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
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

                  final valor = double.tryParse(valorController.text.trim()) ?? 0.0;

                  bool recorrencia = false;
                  final tipoSelecionado = tiposSnapshot.firstWhere(
                        (tipo) => tipo['id'] == selectedTipoPagamento,
                    orElse: () => {},
                  );

                  final parcelavel = tipoSelecionado['Parcelavel'] == true;
                  final usaCartao = tipoSelecionado['UsaCartao'] == true;

                  if (parcelavel && usaCartao) {
                    recorrencia = true;
                  }

                  await transactionService.addGastoPontual(
                    nome: nomeController.text.trim(),
                    valor: valor,
                    idTipoPagamento: selectedTipoPagamento!,
                    idCategoria: selectedCategoria!,
                    idCartao: exigeCartao ? selectedCartao : null,
                    parcelas: isParcelavel ? selectedParcelas : 1,
                    dataCompra: selectedDate,
                    recorrencia: recorrencia,
                  );

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
// lib/dialogs/add_gain_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_service.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

Future<void> showAddGainDialog(BuildContext context) async {
  final TransactionService transactionService = TransactionService();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _AddGainDialogContent(
        transactionService: transactionService,
      );
    },
  );
}

class _AddGainDialogContent extends StatefulWidget {
  final TransactionService transactionService;

  const _AddGainDialogContent({required this.transactionService});

  @override
  _AddGainDialogContentState createState() => _AddGainDialogContentState();
}

class _AddGainDialogContentState extends State<_AddGainDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Widget _buildDialogRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: estiloFonteMonospace.copyWith(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> _salvarGanho() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double valor = double.tryParse(_valorController.text.trim().replaceAll(',', '.')) ?? 0.0;

      await widget.transactionService.addGanhoPontual(
        nome: _nomeController.text.trim(),
        valor: valor,
        dataRecebimento: _selectedDate,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(),
      isDense: true,
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: finBuddyBlue, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Adicionar novo Ganho',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),
                _buildDialogRow('Título', TextFormField(
                  controller: _nomeController,
                  decoration: inputDecoration,
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                )),
                _buildDialogRow('Valor', TextFormField(
                  controller: _valorController,
                  decoration: inputDecoration,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                )),
                _buildDialogRow('Data do ganho.', InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: finBuddyLime, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _isLoading ? null : _salvarGanho,
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text('Salvar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
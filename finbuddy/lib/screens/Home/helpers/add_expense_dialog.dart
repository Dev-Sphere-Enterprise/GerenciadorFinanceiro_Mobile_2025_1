import '../../../../shared/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_service.dart';
import '/../../shared/core/services/firestore_helpers.dart';

Future<void> showAddExpenseDialog(BuildContext context) async {
  final tiposSnapshot = await FirestoreHelpers.getTiposPagamento().first;
  final categoriasSnapshot = await FirestoreHelpers.getCategorias().first;
  final cartoesSnapshot = await FirestoreHelpers.getCartoes().first;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _AddExpenseDialogContent(
        tiposPagamento: tiposSnapshot,
        categorias: categoriasSnapshot,
        cartoes: cartoesSnapshot,
      );
    },
  );
}

class _AddExpenseDialogContent extends StatefulWidget {
  final List<Map<String, dynamic>> tiposPagamento;
  final List<Map<String, dynamic>> categorias;
  final List<Map<String, dynamic>> cartoes;

  const _AddExpenseDialogContent({
    required this.tiposPagamento,
    required this.categorias,
    required this.cartoes,
  });

  @override
  _AddExpenseDialogContentState createState() => _AddExpenseDialogContentState();
}

class _AddExpenseDialogContentState extends State<_AddExpenseDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedTipoPagamento;
  String? _selectedCartao;
  String? _selectedCategoria;
  int _selectedParcelas = 1;
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

  Future<void> _salvarGasto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final valor = double.tryParse(_valorController.text.trim().replaceAll(',', '.')) ?? 0.0;
      final TransactionService transactionService = TransactionService();

      final tipoSelecionado = widget.tiposPagamento.firstWhere(
            (tipo) => tipo['id'] == _selectedTipoPagamento,
        orElse: () => {},
      );

      final isParcelavel = tipoSelecionado['Parcelavel'] == true;
      final exigeCartao = tipoSelecionado['UsaCartao'] == true;
      final recorrencia = isParcelavel && exigeCartao && _selectedParcelas > 1;

      await transactionService.addGastoPontual(
        nome: _nomeController.text.trim(),
        valor: valor,
        idTipoPagamento: _selectedTipoPagamento!,
        idCategoria: _selectedCategoria!,
        idCartao: exigeCartao ? _selectedCartao : null,
        parcelas: isParcelavel ? _selectedParcelas : 1,
        dataCompra: _selectedDate,
        recorrencia: recorrencia,
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
    final tipoAtual = _selectedTipoPagamento != null ? widget.tiposPagamento.firstWhere((t) => t['id'] == _selectedTipoPagamento, orElse: () => {}) : null;
    final bool isParcelavel = tipoAtual?['Parcelavel'] == true;
    final bool exigeCartao = tipoAtual?['UsaCartao'] == true;

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
                  'Adicionar novo Gasto',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),

                _buildDialogRow('Título', TextFormField(controller: _nomeController, decoration: inputDecoration, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Valor', TextFormField(controller: _valorController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),

                _buildDialogRow('Forma de pgto.', DropdownButtonFormField<String>(
                  decoration: inputDecoration,
                  value: _selectedTipoPagamento,
                  items: widget.tiposPagamento.map((t) => DropdownMenuItem<String>(
                    value: t['id'],
                    child: Text(t['nome'] ?? t['Nome'] ?? 'Sem nome', style: estiloFonteMonospace.copyWith(fontSize: 14)),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTipoPagamento = value;
                    });
                  },
                  validator: (v) => v == null ? 'Obrigatório' : null,
                )),

                if (exigeCartao) _buildDialogRow('Selecione o cartão', DropdownButtonFormField<String>(
                  decoration: inputDecoration,
                  value: _selectedCartao,
                  items: widget.cartoes.map((c) => DropdownMenuItem<String>(
                    value: c['id'],
                    child: Text(c['nome'] ?? c['Nome'] ?? 'Sem nome', style: estiloFonteMonospace.copyWith(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCartao = v),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                )),

                if (isParcelavel) _buildDialogRow('Número de parcelas', DropdownButtonFormField<int>(
                  decoration: inputDecoration,
                  value: _selectedParcelas,
                  items: List.generate(24, (i) => i + 1).map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('$p x', style: estiloFonteMonospace.copyWith(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedParcelas = v ?? 1),
                )),

                _buildDialogRow('Categoria', DropdownButtonFormField<String>(
                  decoration: inputDecoration,
                  value: _selectedCategoria,
                  items: widget.categorias.map((c) => DropdownMenuItem<String>(
                    value: c['id'],
                    child: Text(c['nome'] ?? c['Nome'] ?? 'Sem nome', style: estiloFonteMonospace.copyWith(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCategoria = v),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                )),

                _buildDialogRow('Data do pgto.', InkWell(
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
                  onPressed: _isLoading ? null : _salvarGasto,
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
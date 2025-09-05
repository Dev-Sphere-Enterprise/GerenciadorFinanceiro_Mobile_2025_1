import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/gasto_model.dart';
import '../viewmodel/gastos_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';

Future<void> showAddOrEditGastoDialog({required BuildContext context, GastoModel? gasto}) async {
  final viewModel = Provider.of<GastosViewModel>(context, listen: false);

  await showDialog(
    context: context,
    builder: (dialogContext) => ChangeNotifierProvider.value(
      value: viewModel,
      child: _GastoDialogContent(gasto: gasto),
    ),
  );
}

class _GastoDialogContent extends StatefulWidget {
  final GastoModel? gasto;
  const _GastoDialogContent({this.gasto});

  @override
  _GastoDialogContentState createState() => _GastoDialogContentState();
}

class _GastoDialogContentState extends State<_GastoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController, _valorController;
  late DateTime _selectedDate;
  String? _selectedTipo, _selectedCartao, _selectedCategoria;
  int _selectedParcelas = 1;
  bool _isLoading = false;
  bool _isFormValid = false;

  late GastosViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = Provider.of<GastosViewModel>(context, listen: false);

    final gasto = widget.gasto;
    _nomeController = TextEditingController(text: gasto?.nome ?? '');
    _valorController = TextEditingController(text: gasto?.valor.toString().replaceAll('.', ',') ?? '');
    _selectedDate = gasto?.dataCompra ?? DateTime.now();
    _selectedTipo = gasto?.idTipoPagamento;
    _selectedCartao = gasto?.idCartao;
    _selectedCategoria = gasto?.idCategoria;
    _selectedParcelas = gasto?.parcelas ?? 1;

    if (_selectedTipo != null && gasto?.idCartao != null) {
      final tipo = _safeTipoAtual;
      if (tipo?.usaCartao == true) {
        _selectedCartao = gasto!.idCartao;
      }
    }

    _nomeController.addListener(_validateForm);
    _valorController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  @override
  void dispose() {
    _nomeController.removeListener(_validateForm);
    _valorController.removeListener(_validateForm);
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  TipoPagamentoModel? get _safeTipoAtual {
    if (_selectedTipo == null) return null;
    return _viewModel.tiposPagamento.firstWhere((t) => t.id == _selectedTipo, orElse: () => null as TipoPagamentoModel);
  }

  void _validateForm() {
    final tipoAtual = _safeTipoAtual;
    final bool exigeCartao = tipoAtual?.usaCartao ?? false;

    final isValid = _nomeController.text.trim().isNotEmpty &&
        _valorController.text.trim().isNotEmpty &&
        _selectedTipo != null &&
        _selectedCategoria != null &&
        (!exigeCartao || _selectedCartao != null);

    if (mounted && isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _onTipoPagamentoChanged(String? value) {
    setState(() {
      _selectedTipo = value;
      final tipo = _safeTipoAtual;
      if (tipo != null) {
        if (!tipo.parcelavel) _selectedParcelas = 1;
        if (!tipo.usaCartao) _selectedCartao = null;
      }
    });
    // A validação é chamada logo após o setState
    _validateForm();
  }

  Future<void> _salvarGasto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    final valorFinal = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

    if (currentUser == null) {
      // ... (código de erro de usuário não logado)
      return;
    }

    final gasto = GastoModel(
      id: widget.gasto?.id,
      idUsuario: currentUser.uid,
      nome: _nomeController.text.trim(),
      valor: valorFinal,
      dataCompra: _selectedDate,
      idTipoPagamento: _selectedTipo!,
      idCartao: _selectedCartao,
      idCategoria: _selectedCategoria!,
      parcelas: _selectedParcelas,
      dataCriacao: widget.gasto?.dataCriacao ?? DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );

    final sucesso = await _viewModel.salvarGasto(gasto);
    if (mounted) {
      if (sucesso) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar gasto'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDialogRow(String label, Widget child) {
    // ... (sem alterações aqui)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: estiloFonteMonospace.copyWith(fontSize: 14))),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // O Consumer não é mais necessário aqui, pois a tela principal já garante que os dados estão carregados.
    final bool isEditing = widget.gasto != null;
    final tipoAtual = _safeTipoAtual;
    final bool isParcelavel = tipoAtual?.parcelavel ?? false;
    final bool exigeCartao = tipoAtual?.usaCartao ?? false;

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
                Text(isEditing ? 'Editar Gasto' : 'Adicionar novo Gasto', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                const SizedBox(height: 24),
                _buildDialogRow('Título', TextFormField(controller: _nomeController, decoration: inputDecoration, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Valor', TextFormField(controller: _valorController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Forma de pgto.', DropdownButtonFormField<String>(
                  decoration: inputDecoration,
                  value: _selectedTipo,
                  items: _viewModel.tiposPagamento.map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.nome, style: estiloFonteMonospace.copyWith(fontSize: 14)))).toList(),
                  onChanged: _onTipoPagamentoChanged,
                  validator: (v) => v == null ? 'Obrigatório' : null,
                )),
                if (exigeCartao)
                  _buildDialogRow('Cartão', DropdownButtonFormField<String>(
                    decoration: inputDecoration,
                    value: _selectedCartao,
                    items: _viewModel.cartoes.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.nome, style: estiloFonteMonospace.copyWith(fontSize: 14)))).toList(),
                    onChanged: (v) => setState(() { _selectedCartao = v; _validateForm(); }),
                    validator: (v) => v == null ? 'Obrigatório' : null,
                  )),
                if (isParcelavel)
                  _buildDialogRow('Parcelas', DropdownButtonFormField<int>(
                    decoration: inputDecoration,
                    value: _selectedParcelas,
                    items: List.generate(24, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}x'))),
                    onChanged: (v) => setState(() => _selectedParcelas = v!),
                  )),
                _buildDialogRow('Categoria', DropdownButtonFormField<String>(
                  decoration: inputDecoration,
                  value: _selectedCategoria,
                  items: _viewModel.categorias.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.nome, style: estiloFonteMonospace.copyWith(fontSize: 14)))).toList(),
                  onChanged: (v) => setState(() { _selectedCategoria = v; _validateForm(); }),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                )),
                _buildDialogRow('Data do pgto.', InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.centerLeft,
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finBuddyLime,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: (!_isFormValid || _isLoading) ? null : _salvarGasto,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Salvar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
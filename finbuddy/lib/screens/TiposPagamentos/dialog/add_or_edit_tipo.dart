import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';
import '../viewmodel/tipos_pagamento_viewmodel.dart';

Future<void> showAddOrEditTipoDialog({required BuildContext context, TipoPagamentoModel? tipo}) async {
  final viewModel = Provider.of<TiposPagamentoViewModel>(context, listen: false);
  await showDialog(
    context: context,
    builder: (dialogContext) => _TipoDialogContent(viewModel: viewModel, tipo: tipo),
  );
}

class _TipoDialogContent extends StatefulWidget {
  final TiposPagamentoViewModel viewModel;
  final TipoPagamentoModel? tipo;
  const _TipoDialogContent({required this.viewModel, this.tipo});

  @override
  _TipoDialogContentState createState() => _TipoDialogContentState();
}

class _TipoDialogContentState extends State<_TipoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late bool _isParcelavel;
  late bool _isUsaCartao;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.tipo?.nome ?? '');
    _isParcelavel = widget.tipo?.parcelavel ?? false;
    _isUsaCartao = widget.tipo?.usaCartao ?? false;
  }

  Future<void> _salvarTipo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final model = TipoPagamentoModel(
      id: widget.tipo?.id,
      nome: _nomeController.text.trim(),
      parcelavel: _isParcelavel,
      usaCartao: _isUsaCartao,
      dataCriacao: widget.tipo?.dataCriacao ?? DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );

    final sucesso = await widget.viewModel.salvarTipo(model);
    if (mounted) {
      if (sucesso) Navigator.pop(context);
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar')));
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDialogRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: estiloFonteMonospace)),
          Expanded(flex: 2, child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: finBuddyBlue, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.tipo == null ? 'Adicionar Tipo' : 'Editar Tipo', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              _buildDialogRow('Nome:', TextFormField(controller: _nomeController, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true), validator: (v) => v!.trim().isEmpty ? 'Obrigatório' : null)),
              _buildDialogRow('É Parcelável?', Align(alignment: Alignment.centerRight, child: Switch(value: _isParcelavel, onChanged: (v) => setState(() => _isParcelavel = v), activeColor: finBuddyLime))),
              _buildDialogRow('Usa Cartão?', Align(alignment: Alignment.centerRight, child: Switch(value: _isUsaCartao, onChanged: (v) => setState(() => _isUsaCartao = v), activeColor: finBuddyLime))),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: finBuddyLime, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: _isLoading ? null : _salvarTipo,
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text('Salvar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
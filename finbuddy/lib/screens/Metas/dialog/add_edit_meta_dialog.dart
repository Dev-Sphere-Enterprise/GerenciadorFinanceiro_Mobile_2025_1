import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/meta_model.dart';
import '../viewmodel/metas_viewmodel.dart';

Future<void> showAddOrEditMetaDialog({required BuildContext context, MetaModel? meta}) async {
  final viewModel = Provider.of<MetasViewModel>(context, listen: false);

  await showDialog(
    context: context,
    builder: (dialogContext) => _MetaDialogContent(viewModel: viewModel, meta: meta),
  );
}

class _MetaDialogContent extends StatefulWidget {
  final MetasViewModel viewModel;
  final MetaModel? meta;
  const _MetaDialogContent({required this.viewModel, this.meta});

  @override
  _MetaDialogContentState createState() => _MetaDialogContentState();
}

class _MetaDialogContentState extends State<_MetaDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorObjetivoController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.meta?.nome ?? '');
    _valorObjetivoController = TextEditingController(text: widget.meta?.valorObjetivo.toString().replaceAll('.', ',') ?? '');
    _selectedDate = widget.meta?.dataLimiteMeta ?? DateTime.now();
  }

  Future<void> _salvarMeta() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final valor = double.tryParse(_valorObjetivoController.text.replaceAll(',', '.')) ?? 0.0;
    
    final meta = MetaModel(
      id: widget.meta?.id,
      idUsuario: '', 
      nome: _nomeController.text.trim(),
      valorObjetivo: valor,
      valorAtual: widget.meta?.valorAtual ?? 0.0,
      dataLimiteMeta: _selectedDate,
      dataCriacao: widget.meta?.dataCriacao ?? DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );

    final sucesso = await widget.viewModel.salvarMeta(meta);

    if (mounted) {
      if (sucesso) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar meta')));
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDialogRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 100, child: Text(label, style: estiloFonteMonospace.copyWith(fontSize: 14))),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(), isDense: true);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: finBuddyBlue, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.meta == null ? 'Adicionar Meta' : 'Editar Meta', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                const SizedBox(height: 24),
                _buildDialogRow('Nome:', TextFormField(controller: _nomeController, decoration: inputDecoration, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Objetivo (R\$):', TextFormField(controller: _valorObjetivoController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Data Limite:', InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: finBuddyLime, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _isLoading ? null : _salvarMeta,
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
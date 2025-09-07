import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/ganho_model.dart';
import '../viewmodel/ganhos_viewmodel.dart';

Future<void> showAddOrEditGanhoDialog({required BuildContext context, GanhoModel? ganho}) async {
  final viewModel = Provider.of<GanhosViewModel>(context, listen: false);

  await showDialog(
    context: context,
    builder: (dialogContext) => _GanhoDialogContent(viewModel: viewModel, ganho: ganho),
  );
}

class _GanhoDialogContent extends StatefulWidget {
  final GanhosViewModel viewModel;
  final GanhoModel? ganho;
  const _GanhoDialogContent({required this.viewModel, this.ganho});

  @override
  _GanhoDialogContentState createState() => _GanhoDialogContentState();
}

class _GanhoDialogContentState extends State<_GanhoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorController;
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.ganho?.nome ?? '');
    _valorController = TextEditingController(text: widget.ganho?.valor.toString().replaceAll('.', ',') ?? '');
    _selectedDate = widget.ganho?.dataRecebimento ?? DateTime.now();

    _nomeController.addListener(_validateForm);
    _valorController.addListener(_validateForm);
    _validateForm();
  }

  @override
  void dispose() {
    _nomeController.removeListener(_validateForm);
    _valorController.removeListener(_validateForm);
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _nomeController.text.trim().isNotEmpty && _valorController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _salvarGanho() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

    final ganho = GanhoModel(
      id: widget.ganho?.id,
      idUsuario: '', 
      nome: _nomeController.text.trim(),
      valor: valor,
      dataRecebimento: _selectedDate,
      dataCriacao: widget.ganho?.dataCriacao ?? DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );

    final sucesso = await widget.viewModel.salvarGanho(ganho);

    if (mounted) {
      if (sucesso) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar')));
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
          SizedBox(
            width: 100,
            child: Text(label, style: estiloFonteMonospace.copyWith(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.ganho != null;
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
                  isEditing ? 'Editar Ganho Fixo' : 'Adicionar Ganho Fixo',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),
                _buildDialogRow('Nome:', TextFormField(key: const Key('nomeField'),controller: _nomeController, decoration: inputDecoration, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Valor (R\$):', TextFormField( key: const Key('valorField'), controller: _valorController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow(
                  'Data:',
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finBuddyLime,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: (!_isFormValid || _isLoading) ? null : _salvarGanho,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
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
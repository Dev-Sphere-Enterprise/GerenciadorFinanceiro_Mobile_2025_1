import 'package.flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/cartao_model.dart';
import '../viewmodel/cartoes_viewmodel.dart';

Future<void> showAddEditCartaoDialog({
  required BuildContext context,
  CartaoModel? cartao,
}) async {
  final viewModel = Provider.of<CartoesViewModel>(context, listen: false);

  await showDialog(
    context: context,
    builder: (dialogContext) => _CartaoDialogContent(
      viewModel: viewModel,
      cartao: cartao,
    ),
  );
}

class _CartaoDialogContent extends StatefulWidget {
  final CartoesViewModel viewModel;
  final CartaoModel? cartao;

  const _CartaoDialogContent({required this.viewModel, this.cartao});

  @override
  _CartaoDialogContentState createState() => _CartaoDialogContentState();
}

class _CartaoDialogContentState extends State<_CartaoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorFaturaController;
  late TextEditingController _limiteController;
  late DateTime _selectedFechamento;
  late DateTime _selectedVencimento;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.cartao != null;

    _nomeController = TextEditingController(text: isEditing ? widget.cartao!.nome : '');
    _valorFaturaController = TextEditingController(
        text: isEditing ? widget.cartao!.valorFaturaAtual.toStringAsFixed(2).replaceAll('.', ',') : '0,00');
    _limiteController = TextEditingController(
        text: isEditing ? widget.cartao!.limiteCredito.toStringAsFixed(2).replaceAll('.', ',') : '');
    _selectedFechamento = isEditing ? widget.cartao!.dataFechamento : DateTime.now();
    _selectedVencimento = isEditing ? widget.cartao!.dataVencimento : DateTime.now();
    
    _nomeController.addListener(_validateForm);
    _limiteController.addListener(_validateForm);

    _validateForm();
  }

  @override
  void dispose() {
    _nomeController.removeListener(_validateForm);
    _limiteController.removeListener(_validateForm);
    _nomeController.dispose();
    _valorFaturaController.dispose();
    _limiteController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _nomeController.text.trim().isNotEmpty &&
                    _limiteController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }
  
  Future<void> _salvarCartao() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final valorFatura = double.tryParse(_valorFaturaController.text.replaceAll(',', '.')) ?? 0.0;
    final limite = double.tryParse(_limiteController.text.replaceAll(',', '.')) ?? 0.0;
    
    final cartaoParaSalvar = CartaoModel(
      id: widget.cartao?.id,
      idUsuario: '', 
      nome: _nomeController.text.trim(),
      valorFaturaAtual: valorFatura,
      limiteCredito: limite,
      dataFechamento: _selectedFechamento,
      dataVencimento: _selectedVencimento,
      dataCriacao: widget.cartao?.dataCriacao ?? DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );
    
    final sucesso = await widget.viewModel.salvarCartao(cartaoParaSalvar);

    if (mounted) {
      if (sucesso) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar o cartão'), backgroundColor: Colors.red),
        );
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
    final bool isEditing = widget.cartao != null;
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
                  isEditing ? 'Editar Cartão' : 'Adicionar Cartão',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),
                _buildDialogRow('Nome:', TextFormField(controller: _nomeController, decoration: inputDecoration, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Fatura (R\$):', TextFormField(controller: _valorFaturaController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Limite (R\$):', TextFormField(controller: _limiteController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Fechamento:', InkWell(onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: _selectedFechamento, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setState(() => _selectedFechamento = picked);
                }, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.centerLeft, child: Text(DateFormat('dd/MM/yyyy').format(_selectedFechamento), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal))))),
                _buildDialogRow('Vencimento:', InkWell(onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: _selectedVencimento, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setState(() => _selectedVencimento = picked);
                }, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.centerLeft, child: Text(DateFormat('dd/MM/yyyy').format(_selectedVencimento), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal))))),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finBuddyLime,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: (!_isFormValid || _isLoading) ? null : _salvarCartao,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
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
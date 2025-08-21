import 'package.flutter/material.dart';
import 'package.cloud_firestore/cloud_firestore.dart';
import 'package.firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

Future<void> showAddEditCartaoDialog({
  required BuildContext context,
  String? id,
  String? nome,
  double? valorFatura,
  double? limiteCredito,
  DateTime? dataFechamento,
  DateTime? dataVencimento,
}) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _CartaoDialogContent(
        id: id,
        nome: nome,
        valorFatura: valorFatura,
        limiteCredito: limiteCredito,
        dataFechamento: dataFechamento,
        dataVencimento: dataVencimento,
      );
    },
  );
}

class _CartaoDialogContent extends StatefulWidget {
  final String? id, nome;
  final double? valorFatura, limiteCredito;
  final DateTime? dataFechamento, dataVencimento;

  const _CartaoDialogContent({
    this.id, this.nome, this.valorFatura, this.limiteCredito,
    this.dataFechamento, this.dataVencimento,
  });

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

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _valorFaturaController = TextEditingController(text: widget.valorFatura?.toStringAsFixed(2).replaceAll('.', ','));
    _limiteController = TextEditingController(text: widget.limiteCredito?.toStringAsFixed(2).replaceAll('.', ','));
    _selectedFechamento = widget.dataFechamento ?? DateTime.now();
    _selectedVencimento = widget.dataVencimento ?? DateTime.now();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorFaturaController.dispose();
    _limiteController.dispose();
    super.dispose();
  }

  Future<void> _salvarCartao() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Usuário não autenticado.");
      
      final valor = double.tryParse(_valorFaturaController.text.replaceAll(',', '.')) ?? 0.0;
      final limite = double.tryParse(_limiteController.text.replaceAll(',', '.')) ?? 0.0;

      final dataMap = {
        'Nome': _nomeController.text.trim(),
        'Valor_Fatura_Atual': valor,
        'Limite_Credito': limite,
        'Credito_Disponivel': limite - valor,
        'Data_Fechamento': Timestamp.fromDate(_selectedFechamento),
        'Data_Vencimento': Timestamp.fromDate(_selectedVencimento),
        'Deletado': false,
        'Data_Atualizacao': Timestamp.now(),
      };

      final cartoesRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection('cartoes');

      if (widget.id == null) {
        dataMap['Data_Criacao'] = Timestamp.now();
        await cartoesRef.add(dataMap);
      } else {
        await cartoesRef.doc(widget.id).update(dataMap);
      }

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar cartão: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final bool isEditing = widget.id != null;
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
                _buildDialogRow('Fechamento:', InkWell(onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: _selectedFechamento, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (picked != null) setState(() => _selectedFechamento = picked);}, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.centerLeft, child: Text(DateFormat('dd/MM/yyyy').format(_selectedFechamento), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal))))),
                _buildDialogRow('Vencimento:', InkWell(onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: _selectedVencimento, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (picked != null) setState(() => _selectedVencimento = picked);}, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.centerLeft, child: Text(DateFormat('dd/MM/yyyy').format(_selectedVencimento), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal))))),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: finBuddyLime, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _isLoading ? null : _salvarCartao,
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
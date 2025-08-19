import 'package.flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '/../services/firestore_helpers.dart'; // Mantenha o seu import

// --- Constantes de Cores e Estilos ---
const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);
// -------------------------------------

// Função principal que exibe o dialog
Future<void> showAddOrEditGastoDialog({
  required BuildContext context,
  String? gastoId,
  String? nome,
  double? valor,
  DateTime? dataCompra,
  int parcelas = 1,
  String? tipoPagamentoId,
  String? cartaoId,
  String? categoriaId,
}) async {
  // Pré-carrega os dados necessários para os dropdowns
  final tiposSnapshot = await FirestoreHelpers.getTiposPagamento().first;
  final categoriasSnapshot = await FirestoreHelpers.getCategorias().first;
  final cartoesSnapshot = await FirestoreHelpers.getCartoes().first;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      // Usa um widget Stateful para gerenciar o estado complexo do formulário
      return _GastoDialogContent(
        tiposPagamento: tiposSnapshot,
        categorias: categoriasSnapshot,
        cartoes: cartoesSnapshot,
        gastoId: gastoId,
        nome: nome,
        valor: valor,
        dataCompra: dataCompra,
        parcelas: parcelas,
        tipoPagamentoId: tipoPagamentoId,
        cartaoId: cartaoId,
        categoriaId: categoriaId,
      );
    },
  );
}

// Widget Stateful para o conteúdo do dialog
class _GastoDialogContent extends StatefulWidget {
  final List<Map<String, dynamic>> tiposPagamento;
  final List<Map<String, dynamic>> categorias;
  final List<Map<String, dynamic>> cartoes;
  final String? gastoId, nome, tipoPagamentoId, cartaoId, categoriaId;
  final double? valor;
  final DateTime? dataCompra;
  final int parcelas;

  const _GastoDialogContent({
    required this.tiposPagamento,
    required this.categorias,
    required this.cartoes,
    this.gastoId, this.nome, this.valor, this.dataCompra, 
    required this.parcelas, this.tipoPagamentoId, this.cartaoId, this.categoriaId,
  });

  @override
  _GastoDialogContentState createState() => _GastoDialogContentState();
}

class _GastoDialogContentState extends State<_GastoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorController;
  late DateTime _selectedDate;
  String? _selectedTipo, _selectedCartao, _selectedCategoria;
  int? _selectedParcelas;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _valorController = TextEditingController(text: widget.valor?.toStringAsFixed(2).replaceAll('.', ','));
    _selectedDate = widget.dataCompra ?? DateTime.now();
    _selectedTipo = widget.tipoPagamentoId;
    _selectedCartao = widget.cartaoId;
    _selectedCategoria = widget.categoriaId;
    _selectedParcelas = widget.parcelas;
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Usuário não autenticado.");

      final valorFinal = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
      final tipoSelecionado = widget.tiposPagamento.firstWhere((t) => t['id'] == _selectedTipo);

      final gastoMap = {
        'Nome': _nomeController.text.trim(),
        'Valor': valorFinal,
        'ID_Tipo_Pagamento': _selectedTipo,
        'ID_Cartao': tipoSelecionado['UsaCartao'] == true ? _selectedCartao : null,
        'ID_Categoria': _selectedCategoria,
        'Parcelas': tipoSelecionado['Parcelavel'] == true ? _selectedParcelas : 1,
        'Data_Compra': Timestamp.fromDate(_selectedDate),
        'Recorrencia': true, 'Deletado': false,
        'Data_Atualizacao': Timestamp.now(),
      };

      final ref = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection('gastos_fixos');
      if (widget.gastoId == null) {
        gastoMap['Data_Criacao'] = Timestamp.now();
        await ref.add(gastoMap);
      } else {
        await ref.doc(widget.gastoId).update(gastoMap);
      }

      if (mounted) Navigator.of(context).pop();

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
    final bool isEditing = widget.gastoId != null;
    final tipoAtual = _selectedTipo != null ? widget.tiposPagamento.firstWhere((t) => t['id'] == _selectedTipo, orElse: () => {}) : null;
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
                  isEditing ? 'Editar Gasto' : 'Adicionar novo Gasto',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),

                _buildDialogRow('Título', TextFormField(controller: _nomeController, decoration: inputDecoration, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Valor', TextFormField(controller: _valorController, decoration: inputDecoration, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                _buildDialogRow('Forma de pgto.', DropdownButtonFormField<String>(decoration: inputDecoration, value: _selectedTipo, items: widget.tiposPagamento.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['Nome']))).toList(), onChanged: (v){ setState(() { _selectedTipo = v; if (v != null) { final tipo = widget.tiposPagamento.firstWhere((t) => t['id'] == v, orElse: () => {}); if (tipo['Parcelavel'] != true) _selectedParcelas = 1; if (tipo['UsaCartao'] != true) _selectedCartao = null; } });}, validator: (v) => v == null ? 'Obrigatório' : null)),
                if (exigeCartao) _buildDialogRow('Selecione o cartão', DropdownButtonFormField<String>(decoration: inputDecoration, value: _selectedCartao, items: widget.cartoes.map((c) => DropdownMenuItem<String>(value: c['id'], child: Text(c['Nome']))).toList(), onChanged: (v) => setState(() => _selectedCartao = v), validator: (v) => v == null ? 'Obrigatório' : null)),
                if (isParcelavel) _buildDialogRow('Número de parcelas', DropdownButtonFormField<int>(decoration: inputDecoration, value: _selectedParcelas, items: List.generate(24, (i) => i + 1).map((p) => DropdownMenuItem(value: p, child: Text('$p x'))).toList(), onChanged: (v) => setState(() => _selectedParcelas = v))),
                _buildDialogRow('Categoria', DropdownButtonFormField<String>(decoration: inputDecoration, value: _selectedCategoria, items: widget.categorias.map((c) => DropdownMenuItem<String>(value: c['id'], child: Text(c['Nome']))).toList(), onChanged: (v) => setState(() => _selectedCategoria = v), validator: (v) => v == null ? 'Obrigatório' : null)),
                _buildDialogRow('Data do pgto.', InkWell(onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (picked != null) setState(() => _selectedDate = picked);}, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.centerLeft, child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal))))),
                
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

class MetasHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> addOrEditMeta({
    required BuildContext context,
    String? id,
    String? nome,
    double? valorObjetivo,
    DateTime? dataLimite,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _MetaDialogContent(
          id: id,
          nome: nome,
          valorObjetivo: valorObjetivo,
          dataLimite: dataLimite,
        );
      },
    );
  }
}

class _MetaDialogContent extends StatefulWidget {
  final String? id;
  final String? nome;
  final double? valorObjetivo;
  final DateTime? dataLimite;

  const _MetaDialogContent({this.id, this.nome, this.valorObjetivo, this.dataLimite});

  @override
  _MetaDialogContentState createState() => _MetaDialogContentState();
}

class _MetaDialogContentState extends State<_MetaDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorObjetivoController;
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _valorObjetivoController = TextEditingController(
      text: widget.valorObjetivo?.toStringAsFixed(2).replaceAll('.', ','),
    );
    _selectedDate = widget.dataLimite ?? DateTime.now();

    // Adiciona listeners para validar formulário em tempo real
    _nomeController.addListener(_validateForm);
    _valorObjetivoController.addListener(_validateForm);

    _validateForm();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nomeController.text.trim().isNotEmpty &&
          _valorObjetivoController.text.trim().isNotEmpty &&
          _selectedDate != null;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorObjetivoController.dispose();
    super.dispose();
  }

  Future<void> _salvarMeta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Usuário não autenticado.");

      final valor = double.tryParse(
        _valorObjetivoController.text.replaceAll(',', '.'),
      ) ??
          0.0;

      final dataMap = {
        'Nome': _nomeController.text.trim(),
        'Valor_Objetivo': valor,
        'Data_limite_meta': Timestamp.fromDate(_selectedDate),
        'Deletado': false,
        'Data_Atualizacao': Timestamp.now(),
      };

      final metasRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('metas');

      if (widget.id == null) {
        dataMap['Valor_Atual'] = 0.0;
        dataMap['Data_Criacao'] = Timestamp.now();
        await metasRef.add(dataMap);
      } else {
        await metasRef.doc(widget.id).update(dataMap);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar meta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
            child: Text(
              label,
              style: estiloFonteMonospace.copyWith(fontSize: 14),
            ),
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
                  isEditing ? 'Editar Meta' : 'Adicionar Meta',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),

                // Nome
                _buildDialogRow(
                  'Nome:',
                  TextFormField(
                    controller: _nomeController,
                    decoration: inputDecoration,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                ),

                // Valor Objetivo
                _buildDialogRow(
                  'Objetivo (R\$):',
                  TextFormField(
                    controller: _valorObjetivoController,
                    decoration: inputDecoration,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                ),

                // Data Limite
                _buildDialogRow(
                  'Data Limite:',
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _validateForm();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: estiloFonteMonospace.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botão Salvar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finBuddyLime,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed:
                  (!_isFormValid || _isLoading) ? null : _salvarMeta,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Salvar',
                    style: estiloFonteMonospace.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

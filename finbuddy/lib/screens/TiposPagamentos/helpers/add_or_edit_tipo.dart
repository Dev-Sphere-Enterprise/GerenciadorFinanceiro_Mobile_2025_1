import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../shared/constants/style_constants.dart';

Future<void> addOrEditTipo({
  required BuildContext context,
  String? id,
  String? nome,
  bool? parcelavel,
  bool? usaCartao,
}) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _TipoDialogContent(
        id: id,
        nome: nome,
        parcelavel: parcelavel,
        usaCartao: usaCartao,
      );
    },
  );
}

class _TipoDialogContent extends StatefulWidget {
  final String? id;
  final String? nome;
  final bool? parcelavel;
  final bool? usaCartao;

  const _TipoDialogContent({this.id, this.nome, this.parcelavel, this.usaCartao});

  @override
  _TipoDialogContentState createState() => _TipoDialogContentState();
}

class _TipoDialogContentState extends State<_TipoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late bool _isParcelavel;
  late bool _isUsaCartao;
  bool _isLoading = false;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome ?? '');
    _isParcelavel = widget.parcelavel ?? false;
    _isUsaCartao = widget.usaCartao ?? false;
    _validateForm();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }
  void _validateForm() {
    setState(() {
      _isFormValid =
          _nomeController.text.trim().isNotEmpty;
    });
  }

  Future<void> _salvarTipo() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Usuário não autenticado.");

      final dataMap = {
        'Nome': _nomeController.text.trim(),
        'Parcelavel': _isParcelavel,
        'UsaCartao': _isUsaCartao,
        'Deletado': false,
        'Data_Atualizacao': Timestamp.now(),
      };

      final tiposRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection('tipos_pagamentos');

      if (widget.id == null) {
        dataMap['Data_Criacao'] = Timestamp.now();
        await tiposRef.add(dataMap);
      } else {
        await tiposRef.doc(widget.id).update(dataMap);
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

  Widget _buildDialogRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: estiloFonteMonospace),
          ),
          Expanded(
            flex: 2,
            child: child
          ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Tipo' : 'Adicionar Tipo',
                textAlign: TextAlign.center,
                style: estiloFonteMonospace.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 24),
              _buildDialogRow(
                'Nome:',
                TextFormField(
                  controller: _nomeController,
                  decoration: inputDecoration,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Obrigatório' : null,
                  onChanged: (_) => _validateForm(),
                ),

              ),
              _buildDialogRow(
                'É Parcelável?',
                Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: _isParcelavel,
                    onChanged: (value) => setState(() => _isParcelavel = value),
                    activeColor: finBuddyLime,
                  ),
                ),
              ),
              _buildDialogRow(
                'Usa Cartão?',
                Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: _isUsaCartao,
                    onChanged: (value) => setState(() => _isUsaCartao = value),
                    activeColor: finBuddyLime,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: finBuddyLime,
                  padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                onPressed: (!_isFormValid || _isLoading) ? null : _salvarTipo,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) 
                  : Text('Salvar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
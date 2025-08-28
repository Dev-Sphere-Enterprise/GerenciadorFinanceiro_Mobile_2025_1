import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

Future<void> showAddOrEditGanhoDialog({
  required BuildContext context,
  String? id,
  String? nome,
  double? valor,
  DateTime? data,
  required User currentUser,
  required FirebaseFirestore firestore,
}) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _GanhoDialogContent(
        id: id,
        nome: nome,
        valor: valor,
        data: data,
      );
    },
  );
}

class _GanhoDialogContent extends StatefulWidget {
  final String? id;
  final String? nome;
  final double? valor;
  final DateTime? data;

  const _GanhoDialogContent({this.id, this.nome, this.valor, this.data});

  @override
  _GanhoDialogContentState createState() => _GanhoDialogContentState();
}

class _GanhoDialogContentState extends State<_GanhoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _valorController = TextEditingController(
        text: widget.valor?.toStringAsFixed(2).replaceAll('.', ','));
    _selectedDate = widget.data ?? DateTime.now();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvarGanho() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Usuário não autenticado.");

      final valor = double.tryParse(
          _valorController.text.replaceAll(',', '.')) ?? 0.0;

      final dataMap = {
        'Nome': _nomeController.text.trim(),
        'Valor': valor,
        'Data_Recebimento': Timestamp.fromDate(_selectedDate),
        'Recorrencia': true,
        'Deletado': false,
        'Data_Atualizacao': Timestamp.now(),
      };

      final ganhosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('ganhos_fixos');

      if (widget.id == null) {
        dataMap['Data_Criacao'] = Timestamp.now();
        await ganhosRef.add(dataMap);
      } else {
        await ganhosRef.doc(widget.id).update(dataMap);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar ganho: ${e.toString()}'),
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
                label, style: estiloFonteMonospace.copyWith(fontSize: 14)),
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
            child: StatefulBuilder( // precisa do StatefulBuilder para atualizar dentro do dialog
              builder: (context, setDialogState) {
                bool _isFormValid = _nomeController.text
                    .trim()
                    .isNotEmpty &&
                    _valorController.text
                        .trim()
                        .isNotEmpty &&
                    _selectedDate != null;

                void _validateForm() {
                  setDialogState(() {});
                }

                // adiciona listeners
                _nomeController.addListener(_validateForm);
                _valorController.addListener(_validateForm);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'Editar Ganho Fixo' : 'Adicionar Ganho Fixo',
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

                    // Valor
                    _buildDialogRow(
                      'Valor (R\$):',
                      TextFormField(
                        controller: _valorController,
                        decoration: inputDecoration,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),

                    // Data
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
                            setDialogState(() {
                              _selectedDate = picked;
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

                    // Botão salvar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: finBuddyLime,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: (!_isFormValid || _isLoading)
                          ? null
                          : _salvarGanho,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
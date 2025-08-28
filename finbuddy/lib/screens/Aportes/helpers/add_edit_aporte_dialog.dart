import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Constantes de estilo - Inclua estas constantes no mesmo arquivo ou em um arquivo de estilos compartilhado.
const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

Future<void> showAddOrEditAporteDialog({
  required BuildContext context,
  required FirebaseFirestore firestore,
  required User currentUser,
  required String metaId,
  required Future<void> Function() atualizarValorMeta,
  String? id,
  double? valor,
  DateTime? data,
}) async {
  final valorController = TextEditingController(
    text: valor?.toString().replaceAll('.', ',') ?? '',
  );
  DateTime selectedDate = data ?? DateTime.now();
  final isEditing = id != null;
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          bool isLoading = false;
          bool isFormValid =
              valorController.text.trim().isNotEmpty && selectedDate != null;

          // Listener para atualizar a validade do formulário
          valorController.addListener(() {
            setModalState(() {
              isFormValid =
                  valorController.text.trim().isNotEmpty && selectedDate != null;
            });
          });

          const inputDecoration = InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(),
            isDense: true,
          );

          Widget buildDialogRow(String label, Widget child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '$label:',
                    style: estiloFonteMonospace.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: child),
              ],
            );
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: finBuddyBlue, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEditing ? 'Editar Aporte' : 'Adicionar Aporte',
                        textAlign: TextAlign.center,
                        style: estiloFonteMonospace.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 24),

                      // Campo Valor
                      buildDialogRow(
                        'Valor',
                        TextFormField(
                          controller: valorController,
                          decoration: inputDecoration,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                          v!.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo Data
                      buildDialogRow(
                        'Data',
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                                isFormValid = valorController.text
                                    .trim()
                                    .isNotEmpty &&
                                    selectedDate != null;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: (!isFormValid || isLoading)
                            ? null
                            : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() => isLoading = true);
                            try {
                              final valorFinal = double.tryParse(
                                valorController.text
                                    .trim()
                                    .replaceAll(',', '.'),
                              ) ??
                                  0.0;

                              final dataMap = {
                                'Valor': valorFinal,
                                'Data_Aporte':
                                Timestamp.fromDate(selectedDate),
                                'Deletado': false,
                                'Data_Atualizacao': Timestamp.now(),
                              };

                              final ref = firestore
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .collection('metas')
                                  .doc(metaId)
                                  .collection('aportes_meta');

                              if (id == null) {
                                dataMap['Data_Criacao'] =
                                    Timestamp.now();
                                await ref.add(dataMap);
                              } else {
                                await ref.doc(id).update(dataMap);
                              }

                              await atualizarValorMeta();
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Erro ao salvar: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setModalState(() => isLoading = false);
                              }
                            }
                          }
                        },
                        child: isLoading
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
                          style: estiloFonteMonospace.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = '0xFF212121';

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);
// ---------------------------------------------------

Future<void> showCategoriaDialog(BuildContext context, {String? id, String? nome}) async {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController(text: nome ?? '');
  bool isEditing = id != null;

  await showDialog(
    context: context,
    barrierDismissible: true, 
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'Editar Categoria' : 'Nova Categoria',
                      textAlign: TextAlign.center,
                      style: estiloFonteMonospace.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text('Nome:', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: nomeController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'O nome é obrigatório.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: finBuddyLime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: isLoading ? null : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() { isLoading = true; });

                          try {
                            final currentUser = FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              throw Exception("Usuário não autenticado.");
                            }

                            final dataMap = {
                              'Nome': nomeController.text.trim(),
                              'Deletado': false,
                              'Data_Atualizacao': Timestamp.now(),
                            };

                            final categoriasRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .collection('categorias');

                            if (!isEditing) {
                              dataMap['Data_Criacao'] = Timestamp.now();
                              await categoriasRef.add(dataMap);
                            } else {
                              await categoriasRef.doc(id).update(dataMap);
                            }
                            Navigator.of(dialogContext).pop(); 
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao salvar: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                             if (context.mounted) {
                                setState(() { isLoading = false; });
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
                          : Text('Salvar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
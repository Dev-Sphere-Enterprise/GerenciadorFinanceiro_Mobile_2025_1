import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

Future<void> deleteTipo(BuildContext context, String id, String nome) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  await showDialog(
    context: context,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Confirmar Exclusão",
                    style: estiloFonteMonospace.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tem certeza que deseja excluir o tipo de pagamento "$nome"?',
                    textAlign: TextAlign.center,
                    style: estiloFonteMonospace.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          "Cancelar",
                          style: estiloFonteMonospace.copyWith(color: Colors.grey.shade700),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading ? null : () async {
                          setState(() => isLoading = true);
                          try {
                            final tiposRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .collection('tipos_pagamentos');

                            await tiposRef.doc(id).update({
                              'Deletado': true,
                              'Data_Atualizacao': Timestamp.now(),
                            });

                            if (context.mounted) Navigator.of(dialogContext).pop();

                          } catch (e) {
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao excluir: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
                                "Excluir",
                                style: estiloFonteMonospace.copyWith(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showCategoriaDialog(BuildContext context, {String? id, String? nome}) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = _auth.currentUser;

  final nomeController = TextEditingController(text: nome ?? '');

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(id == null ? 'Adicionar Categoria' : 'Editar Categoria'),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: 'Nome da Categoria'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.trim().isEmpty) return;

              final dataMap = {
                'Nome': nomeController.text.trim(),
                'Deletado': false,
                'Data_Atualizacao': Timestamp.now(),
              };

              final categoriasRef = _firestore
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('categorias');

              if (id == null) {
                dataMap['Data_Criacao'] = Timestamp.now();
                await categoriasRef.add(dataMap);
              } else {
                await categoriasRef.doc(id).update(dataMap);
              }

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

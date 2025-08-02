import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> addOrEditTipo({
  required BuildContext context,
  String? id,
  String? nome,
  bool? parcelavel,
  bool? usaCartao,
}) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;

  final nomeController = TextEditingController(text: nome ?? '');
  bool isParcelavel = parcelavel ?? false;
  bool isUsaCartao = usaCartao ?? false;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(id == null ? 'Adicionar Tipo de Pagamento' : 'Editar Tipo de Pagamento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do Tipo de Pagamento'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('É Parcelável?'),
                  value: isParcelavel,
                  onChanged: (value) {
                    setModalState(() {
                      isParcelavel = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text("Usa Cartão?"),
                  value: isUsaCartao,
                  onChanged: (value) {
                    setModalState(() {
                      isUsaCartao = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nomeController.text.trim().isEmpty || currentUser == null) return;

                  final dataMap = {
                    'Nome': nomeController.text.trim(),
                    'Parcelavel': isParcelavel,
                    'UsaCartao': isUsaCartao,
                    'Deletado': false,
                    'Data_Atualizacao': Timestamp.now(),
                  };

                  final tiposRef = _firestore
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('tipos_pagamentos');

                  if (id == null) {
                    dataMap['Data_Criacao'] = Timestamp.now();
                    await tiposRef.add(dataMap);
                  } else {
                    await tiposRef.doc(id).update(dataMap);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );
    },
  );
}

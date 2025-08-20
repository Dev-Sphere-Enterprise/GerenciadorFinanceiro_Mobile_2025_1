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
            backgroundColor: Color(0xFFF5F0ED),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              id == null ? 'Adicionar Tipo de Pagamento' : 'Editar Tipo de Pagamento',
              style: const TextStyle(
                color: Color(0xff3a86e0),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Tipo de Pagamento',
                    labelStyle: const TextStyle(color: Color(0xff3a86e0)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff3a86e0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff3a86e0), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  activeColor: const Color(0xFFC4E03B),
                  title: const Text(
                    'É Parcelável?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  value: isParcelavel,
                  onChanged: (value) {
                    setModalState(() {
                      isParcelavel = value;
                    });
                  },
                ),

                SwitchListTile(
                  activeColor: const Color(0xFFC4E03B),
                  title: const Text(
                    "Usa Cartão?",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  value: isUsaCartao,
                  onChanged: (value) {
                    setModalState(() {
                      isUsaCartao = value;
                    });
                  },
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4E03B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}


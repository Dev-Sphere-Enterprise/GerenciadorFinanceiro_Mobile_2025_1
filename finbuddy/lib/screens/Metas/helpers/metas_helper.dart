// metas_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MetasHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> addOrEditMeta({
    required BuildContext context,
    String? id,
    String? nome,
    double? valorObjetivo,
    DateTime? dataLimite,
  }) async {
    final nomeController = TextEditingController(text: nome ?? '');
    final valorObjetivoController = TextEditingController(text: valorObjetivo?.toString() ?? '');
    DateTime selectedDate = dataLimite ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(id == null ? 'Adicionar Meta' : 'Editar Meta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome da Meta'),
                ),
                TextField(
                  controller: valorObjetivoController,
                  decoration: const InputDecoration(labelText: 'Valor Objetivo (R\$)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1925),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setModalState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text("Data Limite: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
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
                  if (nomeController.text.trim().isEmpty || valorObjetivoController.text.trim().isEmpty) return;

                  final valor = double.tryParse(valorObjetivoController.text.trim()) ?? 0.0;
                  final dataMap = {
                    'Nome': nomeController.text.trim(),
                    'Valor_Objetivo': valor,
                    'Valor_Atual': 0.0,
                    'Data_limite_meta': Timestamp.fromDate(selectedDate),
                    'Deletado': false,
                    'Data_Atualizacao': Timestamp.now(),
                  };

                  final metasRef = _firestore.collection('users').doc(currentUser!.uid).collection('metas');

                  if (id == null) {
                    dataMap['Data_Criacao'] = Timestamp.now();
                    await metasRef.add(dataMap);
                  } else {
                    await metasRef.doc(id).update(dataMap);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

}

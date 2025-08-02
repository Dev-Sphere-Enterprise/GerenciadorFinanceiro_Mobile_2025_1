import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> deleteGasto(BuildContext context, String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('gastos_fixos');

  await ref.doc(id).update({
    'Deletado': true,
    'Data_Atualizacao': Timestamp.now(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gasto deletado com sucesso')),
  );
}

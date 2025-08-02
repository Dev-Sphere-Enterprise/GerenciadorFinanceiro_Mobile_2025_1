import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> deleteCartao(BuildContext context, String id) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  if (currentUser == null) return;

  final cartoesRef = firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('cartoes');

  await cartoesRef.doc(id).update({
    'Deletado': true,
    'Data_Atualizacao': Timestamp.now(),
  });
}

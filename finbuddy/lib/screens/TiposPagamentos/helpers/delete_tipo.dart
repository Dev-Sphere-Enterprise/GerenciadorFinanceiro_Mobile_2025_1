import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> deleteTipo(String id) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;
  if (currentUser == null) return;

  final tiposRef = _firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('tipos_pagamentos');

  await tiposRef.doc(id).update({
    'Deletado': true,
    'Data_Atualizacao': Timestamp.now(),
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<Map<String, dynamic>>> getTiposUsuario() {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;
  if (currentUser == null) {
    // Retorna stream vazio se usuário não autenticado
    return const Stream.empty();
  }

  return _firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('tipos_pagamentos')
      .where('Deletado', isEqualTo: false)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      'Nome': doc['Nome'] ?? '',
      'Parcelavel': doc['Parcelavel'] ?? false,
      'UsaCartao': doc['UsaCartao'] ?? false,
      'isGeneral': false,
    })
        .toList(),
  );
}

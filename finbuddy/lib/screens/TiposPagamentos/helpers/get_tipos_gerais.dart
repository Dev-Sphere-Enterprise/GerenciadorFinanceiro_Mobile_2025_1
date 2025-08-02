import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Map<String, dynamic>>> getTiposGerais() {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return _firestore.collection('tipo_pagamentos_gerais').snapshots().map(
        (snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      'Nome': doc['nome'] ?? '',
      'Parcelavel': doc['Parcelavel'] ?? false,
      'UsaCartao': doc['UsaCartao'] ?? false,
      'isGeneral': true,
    })
        .toList(),
  );
}

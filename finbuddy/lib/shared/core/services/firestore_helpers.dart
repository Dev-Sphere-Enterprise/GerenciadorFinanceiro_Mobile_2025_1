import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';

class FirestoreHelpers {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<List<Map<String, dynamic>>> getCartoes() {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cartoes')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, 'nome': doc['Nome'] ?? ''})
          .toList(),
    );
  }

  static Stream<List<Map<String, dynamic>>> getTiposPagamento() {
    final tiposGerais = _firestore.collection('tipo_pagamentos_gerais').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => {
        'id': doc.id,
        'nome': doc['nome'],
        'isGeneral': true,
        'Parcelavel': doc['Parcelavel'] ?? false,
        'UsaCartao': doc['UsaCartao'] ?? false,
      }).toList(),
    );

    final tiposUsuario = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tipos_pagamentos')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
      'id': doc.id,
      'nome': doc['Nome'],
      'isGeneral': false,
      'Parcelavel': doc['Parcelavel'] ?? false,
      'UsaCartao': doc['UsaCartao'] ?? false,
    }).toList(),
    );

    return StreamZip([tiposGerais, tiposUsuario]).map((lists) => [...lists[0], ...lists[1]]);
  }

  static Stream<List<Map<String, dynamic>>> getCategorias() {
    final categoriasGerais = _firestore.collection('categorias_gerais').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, 'nome': doc['nome'], 'isGeneral': true})
          .toList(),
    );

    final categoriasUsuario = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('categorias')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, 'nome': doc['Nome'], 'isGeneral': false})
          .toList(),
    );

    return StreamZip([categoriasGerais, categoriasUsuario])
        .map((lists) => [...lists[0], ...lists[1]]);
  }
}

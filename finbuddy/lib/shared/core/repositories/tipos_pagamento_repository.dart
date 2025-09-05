import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tipo_pagamento_model.dart';
class TipoPagamentoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<TipoPagamentoModel>> getTiposStream() {
    if (_currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('tipos_pagamentos')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TipoPagamentoModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addOrEditTipo(TipoPagamentoModel tipo) async {
    if (_currentUser == null) return;

    final ref = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('tipos_pagamentos');

    final data = tipo.toMap();

    if (tipo.id == null) {
      await ref.add(data);
    } else {
      data.remove('Data_Criacao');
      await ref.doc(tipo.id).update(data);
    }
  }

  Future<void> deleteTipo(String tipoId) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('tipos_pagamentos')
        .doc(tipoId)
        .update({
      'Deletado': true,
      'Data_Atualizacao': Timestamp.now(),
    });
  }

  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final snap = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('tipos_pagamentos')
        .where('Deletado', isEqualTo: false)
        .get();

    return snap.docs
        .map((d) => TipoPagamentoModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<List<TipoPagamentoModel>> getTiposGerais() async {
    final snap = await _firestore
        .collection('tipo_pagamentos_gerais')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return TipoPagamentoModel(
        id: doc.id,
        nome: data['nome'] ?? '',
        usaCartao: data['UsaCartao'] ?? false,
        parcelavel: data['Parcelavel'] ?? false,
        deletado: false,
        dataCriacao: null,
        dataAtualizacao: DateTime.now(),
      );
    }).toList();
  }

}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gasto_model.dart';
import '../models/categoria_model.dart';
import '../models/cartao_model.dart';
import '../models/tipo_pagamento_model.dart';

class GastosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<GastoModel>> getGastosFixosStream() {
    if (_currentUser == null) return Stream.value([]);
    return _firestore
        .collection('users').doc(_currentUser!.uid).collection('gastos')
        .where('Deletado', isEqualTo: false)
        .where('Recorrencia', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GastoModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addOrEditGasto(GastoModel gasto) async {
    if (_currentUser == null) return;
    final ref = _firestore.collection('users').doc(_currentUser!.uid).collection('gastos');
    final data = gasto.toMap();
    if (gasto.id == null) {
      await ref.add(data);
    } else {
      data.remove('Data_Criacao');
      await ref.doc(gasto.id).update(data);
    }
  }

  Future<void> deleteGasto(String gastoId) async {
    if (_currentUser == null) return;
    await _firestore.collection('users').doc(_currentUser!.uid).collection('gastos')
        .doc(gastoId).update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
  }

  Future<List<CategoriaModel>> getCategorias() async {
    if (_currentUser == null) return [];
    final userCatSnap = await _firestore.collection('users').doc(_currentUser!.uid).collection('categorias').where('Deletado', isEqualTo: false).get();
    final geraisCatSnap = await _firestore.collection('categorias_gerais').get();
    
    final userCategorias = userCatSnap.docs.map((d) => CategoriaModel.fromMap(d.id, d.data())).toList();
    final geraisCategorias = geraisCatSnap.docs.map((d) => CategoriaModel.fromMap(d.id, d.data())).toList();
    
    return [...userCategorias, ...geraisCategorias];
  }

  Future<List<CartaoModel>> getCartoes() async {
    if (_currentUser == null) return [];
    final snap = await _firestore.collection('users').doc(_currentUser!.uid).collection('cartoes').where('Deletado', isEqualTo: false).get();
    return snap.docs.map((d) => CartaoModel.fromMap(d.id, d.data())).toList();
  }

  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
     if (_currentUser == null) return [];
    final snap = await _firestore.collection('users').doc(_currentUser!.uid).collection('tipos_pagamento').where('Deletado', isEqualTo: false).get();
    return snap.docs.map((d) => TipoPagamentoModel.fromMap(d.id, d.data())).toList();
  }
}
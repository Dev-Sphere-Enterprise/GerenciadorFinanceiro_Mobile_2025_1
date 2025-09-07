import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gasto_model.dart';

class GastosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<GastoModel>> getGastosFixosStream() {
    if (_currentUser == null) return Stream.value([]);
    return _firestore
        .collection('users').doc(_currentUser!.uid).collection('gastos_fixos')
        .where('Deletado', isEqualTo: false)
        .where('Recorrencia', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GastoModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addOrEditGasto(GastoModel gasto) async {
    if (_currentUser == null) return;
    final ref = _firestore.collection('users').doc(_currentUser!.uid).collection('gastos_fixos');
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
    await _firestore.collection('users').doc(_currentUser!.uid).collection('gastos_fixos')
        .doc(gastoId).update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
  }

  Future<void> addGastoPontual(GastoModel gasto) async {
    final gastoNaoRecorrente = gasto.copyWith(recorrencia: false);
    await addOrEditGasto(gastoNaoRecorrente);
  }
}
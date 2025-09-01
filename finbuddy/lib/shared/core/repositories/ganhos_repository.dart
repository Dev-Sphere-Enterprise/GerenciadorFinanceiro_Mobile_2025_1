import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ganho_model.dart';

class GanhosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<GanhoModel>> getGanhosFixosStream() {
    if (_currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users').doc(_currentUser!.uid).collection('ganhos')
        .where('Deletado', isEqualTo: false)
        .where('Recorrencia', isEqualTo: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GanhoModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addOrEditGanho(GanhoModel ganho) async {
    if (_currentUser == null) return;
    
    final ref = _firestore.collection('users').doc(_currentUser!.uid).collection('ganhos');
    final data = ganho.toMap();

    if (ganho.id == null) {
      await ref.add(data);
    } else {
      data.remove('Data_Criacao');
      await ref.doc(ganho.id).update(data);
    }
  }

  Future<void> deleteGanho(String ganhoId) async {
    if (_currentUser == null) return;
    
    await _firestore
        .collection('users').doc(_currentUser!.uid).collection('ganhos')
        .doc(ganhoId)
        .update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
  }
}
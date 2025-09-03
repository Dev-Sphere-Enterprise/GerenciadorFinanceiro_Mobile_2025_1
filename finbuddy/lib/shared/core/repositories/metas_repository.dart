import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meta_model.dart';
import '../models/aporte_meta_model.dart'; 

class MetasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<MetaModel>> getMetasStream() {
    if (_currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users').doc(_currentUser!.uid).collection('metas')
        .where('Deletado', isEqualTo: false)
        .orderBy('Data_limite_meta')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MetaModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addOrEditMeta(MetaModel meta) async {
    if (_currentUser == null) return;
    
    final ref = _firestore.collection('users').doc(_currentUser!.uid).collection('metas');
    final data = meta.toMap();

    if (meta.id == null) {
      data['Valor_Atual'] = 0.0; 
      await ref.add(data);
    } else {
      data.remove('Data_Criacao');
      data.remove('Valor_Atual');
      await ref.doc(meta.id).update(data);
    }
  }

  Future<void> deleteMeta(String metaId) async {
    if (_currentUser == null) return;
    
    await _firestore
        .collection('users').doc(_currentUser!.uid).collection('metas')
        .doc(metaId)
        .update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
  }

  Future<void> recalcularEAtualizarValorMeta(String metaId) async {
    if (_currentUser == null) {
      throw Exception("Usuário não autenticado.");
    }

    final snapshot = await _firestore
        .collection('users').doc(_currentUser!.uid).collection('metas')
        .doc(metaId).collection('aportes_meta')
        .where('Deletado', isEqualTo: false)
        .get();

    final aportes = snapshot.docs.map((doc) => 
        AporteMetaModel.fromMap(doc.id, doc.data())
    ).toList();
    
    final double total = aportes.fold(0.0, (soma, aporte) => soma + aporte.valor);

    await _firestore
        .collection('users').doc(_currentUser!.uid).collection('metas')
        .doc(metaId)
        .update({
      'Valor_Atual': total,
      'Data_Atualizacao': Timestamp.now(),
    });
  }
}
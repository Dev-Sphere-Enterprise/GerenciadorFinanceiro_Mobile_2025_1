import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/aporte_meta_model.dart';
import 'metas_repository.dart';
class AportesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MetasRepository _metasRepository;

  AportesRepository() : _metasRepository = MetasRepository();

  User? get _currentUser => _auth.currentUser;

  Stream<List<AporteMetaModel>> getAportesStream(String metaId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    
    final ref = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('metas')
        .doc(metaId)
        .collection('aportes_meta')
        .where('Deletado', isEqualTo: false);
        // .orderBy('Data_Aporte', descending: true);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AporteMetaModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> recalcularEAtualizarValorMeta (String metaId) async {
    if (_currentUser == null) return;
    final currentUser = _currentUser!;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('metas')
        .doc(metaId)
        .collection('aportes_meta')
        .where('Deletado', isEqualTo: false)
        .get();

    double total = snapshot.docs.fold(0.0, (somaAnterior, doc) {
      final aporte = AporteMetaModel.fromMap(doc.id, doc.data());
      return somaAnterior + aporte.valor;
    });

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('metas')
        .doc(metaId)
        .update({
      'Valor_Atual': total,
      'Data_Atualizacao': Timestamp.now(),
    });
  }

  Future<void> addOrEditAporte(String metaId, AporteMetaModel aporte) async {
    if (_currentUser == null) return;

    final ref = _firestore
        .collection('users').doc(_currentUser!.uid).collection('metas')
        .doc(metaId).collection('aportes_meta');

    final data = aporte.toMap();
    
    if (aporte.id == null) {
      data['Data_Criacao'] = Timestamp.now();
      await ref.add(data);
    } else {
      data.remove('Data_Criacao');
      await ref.doc(aporte.id).update(data);
    }

    await _metasRepository.recalcularEAtualizarValorMeta(metaId);
  }

  Future<void> deleteAporte(String metaId, String aporteId) async {
    if (_currentUser == null) return;
    
    await _firestore
        .collection('users').doc(_currentUser!.uid).collection('metas')
        .doc(metaId).collection('aportes_meta')
        .doc(aporteId)
        .update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
    
    await _metasRepository.recalcularEAtualizarValorMeta(metaId);
  }
}
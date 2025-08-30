import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aporte_meta_model.dart';

class MetasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> recalcularEAtualizarValorMeta(String metaId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('metas')
        .doc(metaId)
        .collection('aportes_meta')
        .where('Deletado', isEqualTo: false)
        .get();

    final aportes = snapshot.docs.map((doc) => 
        AporteMetaModel.fromMap(doc.id, doc.data())
    ).toList();
    
    final double total = aportes.fold(0.0, (soma, aporte) => soma + aporte.valor);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('metas')
        .doc(metaId)
        .update({
      'Valor_Atual': total,
      'Data_Atualizacao': Timestamp.now(),
    });
  }
}
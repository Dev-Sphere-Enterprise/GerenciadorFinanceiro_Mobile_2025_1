import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/core/models/aporte_meta_model.dart';

Future<void> atualizarValorMetaComModel({
  required FirebaseFirestore firestore,
  required User currentUser,
  required String metaId,
}) async {
  final snapshot = await firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('metas')
      .doc(metaId)
      .collection('aportes_meta')
      .where('Deletado', isEqualTo: false)
      .get();

  final aportes = snapshot.docs.map((doc) {
    return AporteMetaModel.fromMap(doc.id, doc.data());
  }).toList();

  double total = aportes.fold(0.0, (somaAnterior, aporte) => somaAnterior + aporte.valor);
  
  await firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('metas')
      .doc(metaId)
      .update({
    'Valor_Atual': total,
    'Data_Atualizacao': Timestamp.now(),
  });
}
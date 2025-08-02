import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> atualizarValorMeta({
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

  double total = 0;
  for (var doc in snapshot.docs) {
    total += (doc['Valor'] ?? 0).toDouble();
  }

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

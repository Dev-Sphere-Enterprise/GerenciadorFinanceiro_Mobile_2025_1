import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> deleteGanho({
  required String id,
  required User currentUser,
  required FirebaseFirestore firestore,
}) async {
  final ganhosRef = firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('ganhos_fixos');

  await ganhosRef.doc(id).update({
    'Deletado': true,
    'Data_Atualizacao': Timestamp.now(),
  });
}

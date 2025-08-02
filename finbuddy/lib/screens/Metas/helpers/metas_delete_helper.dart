// metas_delete_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> deleteMeta(String id) async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) {
    throw Exception('Usuário não autenticado');
  }

  await _firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('metas')
      .doc(id)
      .update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
}

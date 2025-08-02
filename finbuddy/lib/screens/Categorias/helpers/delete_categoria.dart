import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> deleteCategoria(String id) async {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    throw Exception('Usuário não autenticado.');
  }

  final categoriasRef = _firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('categorias');

  await categoriasRef.doc(id).update({
    'Deletado': true,
    'Data_Atualizacao': Timestamp.now(),
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
final User? currentUser = _auth.currentUser;

Stream<List<Map<String, dynamic>>> getCategoriasUsuario() {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Stream.empty();
  }

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('categorias')
      .where('Deletado', isEqualTo: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'Nome': doc['Nome'] ?? '',
        'isGeneral': false,
      };
    }).toList();
  });
}
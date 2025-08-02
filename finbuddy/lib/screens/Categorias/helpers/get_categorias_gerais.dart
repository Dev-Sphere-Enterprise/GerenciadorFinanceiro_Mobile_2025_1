import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Stream<List<Map<String, dynamic>>> getCategoriasGerais() {
  return _firestore.collection('categorias_gerais').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'Nome': doc['nome'] ?? '',
        'isGeneral': true,
      };
    }).toList();
  });
}

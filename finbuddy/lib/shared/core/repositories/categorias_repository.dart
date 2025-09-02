import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import '../models/categoria_model.dart';

class CategoriasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<CategoriaModel>> getCategoriasStream() {
    final streamGerais = _getCategoriasGeraisStream();
    final streamUsuario = _getCategoriasUsuarioStream();
    
    return StreamZip([streamGerais, streamUsuario])
        .map((listas) => [...listas[0], ...listas[1]]);
  }

  Stream<List<CategoriaModel>> _getCategoriasGeraisStream() {
    return _firestore.collection('categorias_gerais').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoriaModel.fromMap(doc.id, doc.data()).copyWith(isGeneral: true))
          .toList();
    });
  }

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

  Stream<List<CategoriaModel>> _getCategoriasUsuarioStream() {
    if (_currentUser == null) return Stream.value([]);
    return _firestore
        .collection('users').doc(_currentUser!.uid).collection('categorias')
        .where('Deletado', isEqualTo: false).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoriaModel.fromMap(doc.id, doc.data()).copyWith(isGeneral: false))
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getCategoriasUsuario() {
    if (_currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_currentUser?.uid)
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

  Future<void> addOrEditCategoria(CategoriaModel categoria) async {
    if (_currentUser == null) return;
    
    final ref = _firestore.collection('users').doc(_currentUser!.uid).collection('categorias');
    final data = categoria.toMap();

    if (categoria.id == null) {
      await ref.add(data);
    } else {
      data.remove('Data_Criacao');
      await ref.doc(categoria.id).update(data);
    }
  }

  Future<void> deleteCategoria(String categoriaId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users').doc(_currentUser!.uid).collection('categorias')
        .doc(categoriaId).update({'Deletado': true});
  }

  Future<List<CategoriaModel>> getCategorias() async {
    if (_currentUser == null) return [];
    final userCatSnap = await _firestore.collection('users').doc(_currentUser!.uid).collection('categorias').where('Deletado', isEqualTo: false).get();
    final geraisCatSnap = await _firestore.collection('categorias_gerais').get();
    
    final userCategorias = userCatSnap.docs.map((d) => CategoriaModel.fromMap(d.id, d.data())).toList();
    final geraisCategorias = geraisCatSnap.docs.map((d) => CategoriaModel.fromMap(d.id, d.data())).toList();
    
    return [...userCategorias, ...geraisCategorias];
  }
}
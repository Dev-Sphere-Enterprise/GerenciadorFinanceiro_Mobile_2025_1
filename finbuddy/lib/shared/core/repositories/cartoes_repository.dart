import 'package.cloud_firestore/cloud_firestore.dart';
import 'package.firebase_auth/firebase_auth.dart';
import '../models/cartao_model.dart';

class CartoesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<List<CartaoModel>> getCartoesStream() {
    if (_currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('cartoes')
        .where('Deletado', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartaoModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addOrEditCartao(CartaoModel cartao) async {
    if (_currentUser == null) return;
    
    final ref = _firestore.collection('users').doc(_currentUser!.uid).collection('cartoes');
    final data = cartao.toMap();

    if (cartao.id == null) {
      await ref.add(data);
    } else {
      data.remove('Data_Criacao'); 
      await ref.doc(cartao.id).update(data);
    }
  }

  Future<void> deleteCartao(String cartaoId) async {
    if (_currentUser == null) return;
    
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('cartoes')
        .doc(cartaoId)
        .update({'Deletado': true, 'Data_Atualizacao': Timestamp.now()});
  }
}
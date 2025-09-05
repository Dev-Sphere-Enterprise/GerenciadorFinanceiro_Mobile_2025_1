import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> updateUserProfile(String newName, DateTime newDob) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'nome': newName,
        'dob': Timestamp.fromDate(newDob),
        'dataAtualizacao': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
      throw Exception('Falha ao atualizar o perfil. Tente novamente.');
    }
  }

  Future<UsuarioModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return UsuarioModel.fromMap(doc.id, doc.data()!);
      }
    } catch (e) {
      print('Erro ao buscar perfil do usuário: $e');
    }

    return null;
  }

  Future<UserCredential> signInWithGoogle({
    required Function(String?) setErrorMessage,
  }) async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        setErrorMessage(null);
        throw FirebaseAuthException(code: 'user-cancelled-by-user');
      }

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if the user's document exists in Firestore.
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        // If not, create the profile document with a default name, email, and createdAt.
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'nome': userCredential.user!.displayName ?? 'Usuário',
          'email': userCredential.user!.email,
          'createdAt': Timestamp.now(),
          'dob': null, // 'dob' is nullable, so it can be left blank here.
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      setErrorMessage('Erro de autenticação: ${e.message}');
      rethrow;
    } catch (e) {
      setErrorMessage('Erro inesperado: $e');
      throw Exception('Erro inesperado durante o login com Google.');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String nome,
    required DateTime dob,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final novoUsuario = UsuarioModel(
          id: user.uid,
          nome: nome,
          dob: dob,
          email: email,
          senha: '',
          dataCriacao: DateTime.now(),
          dataAtualizacao: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(novoUsuario.toMap());
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
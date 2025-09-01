import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package.google_sign_in/google_sign_in.dart';
import '../models/usuario_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow; 
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(code: 'USER_CANCELLED');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String nome,
    required DateTime dataNascimento,
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
          dataNascimento: dataNascimento,
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
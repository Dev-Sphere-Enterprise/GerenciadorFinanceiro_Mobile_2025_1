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
    // Acessa o usuário atual do Firebase Auth
    final user = _auth.currentUser;

    // Se não houver usuário logado, interrompe a execução
    if (user == null) {
      return;
    }

    try {
      // Atualiza os campos 'Nome' e 'Data_Nascimento' no Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'Nome': newName,
        'Data_Nascimento': Timestamp.fromDate(newDob),
        'Data_Atualizacao': Timestamp.now(),
      });
    } catch (e) {
      // Trata qualquer erro na atualização
      print('Erro ao atualizar perfil do usuário: $e');
      throw Exception('Falha ao atualizar o perfil. Tente novamente.');
    }
  }

  Future<UsuarioModel?> getCurrentUserProfile() async {
    // Acessa o usuário atual do Firebase Auth
    final user = _auth.currentUser;

    // Se não houver usuário logado, retorna null
    if (user == null) {
      return null;
    }

    try {
      // Acessa o documento do usuário na coleção 'users'
      final doc = await _firestore.collection('users').doc(user.uid).get();

      // Se o documento existe, converte os dados para o modelo e retorna
      if (doc.exists) {
        return UsuarioModel.fromMap(doc.id, doc.data()!);
      }
    } catch (e) {
      // Trata qualquer erro na busca, como falta de permissão
      print('Erro ao buscar perfil do usuário: $e');
    }

    // Se o documento não existe ou houve um erro, retorna null
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

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase Auth
      setErrorMessage('Erro de autenticação: ${e.message}');
      rethrow; // Propaga o erro para quem chamou a função
    } catch (e) {
      // Trata outros tipos de erros
      setErrorMessage('Erro inesperado: $e');
      throw Exception('Erro inesperado durante o login com Google.');
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
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
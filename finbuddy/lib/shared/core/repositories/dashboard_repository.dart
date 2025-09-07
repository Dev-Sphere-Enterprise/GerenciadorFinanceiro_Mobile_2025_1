import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  Future<void> runStartupTasks() async {
    if (_currentUser == null) return;
    if (kDebugMode) {
      print("Tarefas de inicialização executadas (simulação).");
    }
  }

  Future<Map<String, double>> getBalanceData() async {
    if (_currentUser == null) return {'saldo': 0.0, 'gastos': 0.0};

    final ganhosSnap = await _firestore.collection('users').doc(_currentUser!.uid).collection('ganhos_fixos').where('Deletado', isEqualTo: false).get();
    // ignore: avoid_types_as_parameter_names
    double totalGanho = ganhosSnap.docs.fold(0.0, (sum, doc) => sum + (doc.data()['Valor'] as num));

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final gastosMesSnap = await _firestore.collection('users').doc(_currentUser!.uid).collection('gastos_fixos')
        .where('Data_Compra', isGreaterThanOrEqualTo: startOfMonth)
        .where('Data_Compra', isLessThanOrEqualTo: endOfMonth)
        .where('Deletado', isEqualTo: false).get();
    // ignore: avoid_types_as_parameter_names
    double gastosDoMes = gastosMesSnap.docs.fold(0.0, (sum, doc) => sum + (doc.data()['Valor'] as num));
    
    final gastosTotaisSnap = await _firestore.collection('users').doc(_currentUser!.uid).collection('gastos').where('Deletado', isEqualTo: false).get();
    // ignore: avoid_types_as_parameter_names
    double gastosTotais = gastosTotaisSnap.docs.fold(0.0, (sum, doc) => sum + (doc.data()['Valor'] as num));

    return {
      'saldo': totalGanho - gastosTotais,
      'gastos': gastosDoMes,
    };
  }
}
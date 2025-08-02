// lib/services/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> atualizarGanhosFixosVencidos() async {
    final hoje = DateTime.now();
    final user = _auth.currentUser;
    if (user == null) return;

    final ganhosRef =
    _firestore.collection('users').doc(user.uid).collection('ganhos_fixos');

    final snapshot = await ganhosRef.where('Deletado', isEqualTo: false).get();

    for (var doc in snapshot.docs) {
      final dados = doc.data();
      final Timestamp? ts = dados['Data_Recebimento'];
      if (ts == null) continue;

      final dataRecebimento = ts.toDate();
      if (!dataRecebimento.isBefore(hoje) &&
          !dataRecebimento.isAtSameMomentAs(hoje)) {
        continue;
      }

      final novaData = _proximaDataMensal(dataRecebimento);
      await doc.reference.update({
        'Data_Recebimento': Timestamp.fromDate(novaData),
        'Data_Atualizacao': Timestamp.now(),
      });
    }
  }

  Future<void> atualizarDatasCartoesVencidos() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final cartoesRef =
    _firestore.collection('users').doc(currentUser.uid).collection('cartoes');

    final snapshot = await cartoesRef.where('Deletado', isEqualTo: false).get();

    final hoje = DateTime.now();

    for (var doc in snapshot.docs) {
      final dataVencimentoTimestamp = doc['Data_Vencimento'] as Timestamp?;
      final dataFechamentoTimestamp = doc['Data_Fechamento'] as Timestamp?;

      if (dataVencimentoTimestamp == null || dataFechamentoTimestamp == null) {
        continue;
      }

      final dataVencimento = dataVencimentoTimestamp.toDate();
      final dataFechamento = dataFechamentoTimestamp.toDate();

      if (!hoje.isBefore(dataVencimento)) {
        final novaDataVencimento = _proximaDataMensal(dataVencimento);
        final novaDataFechamento = _proximaDataMensal(dataFechamento);

        await doc.reference.update({
          'Data_Vencimento': Timestamp.fromDate(novaDataVencimento),
          'Data_Fechamento': Timestamp.fromDate(novaDataFechamento),
          'Data_Atualizacao': Timestamp.now(),
        });
      }
    }
  }

  DateTime _proximaDataMensal(DateTime dataOriginal) {
    final proximoMes = dataOriginal.month + 1;
    final ano = proximoMes > 12 ? dataOriginal.year + 1 : dataOriginal.year;
    final mes = proximoMes > 12 ? 1 : proximoMes;

    final ultimoDiaMes = DateTime(ano, mes + 1, 0).day;
    final dia =
    dataOriginal.day > ultimoDiaMes ? ultimoDiaMes : dataOriginal.day;

    return DateTime(ano, mes, dia);
  }

  Future<void> processarParcelasPendentes() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final hoje = Timestamp.fromDate(DateTime.now());

    final parcelas = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('parcelas_agendadas')
        .where('Data', isLessThanOrEqualTo: hoje)
        .where('Processado', isEqualTo: false)
        .get();

    for (var doc in parcelas.docs) {
      final data = doc.data();
      final cartaoId = data['ID_Cartao'];
      final valorParcela = data['Valor_Parcela'];

      final cartaoRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cartoes')
          .doc(cartaoId);

      final cartaoSnapshot = await cartaoRef.get();
      final cartaoData = cartaoSnapshot.data();
      if (cartaoData == null) continue;

      final novaFatura =
          (cartaoData['Valor_Fatura_Atual'] ?? 0.0) + valorParcela;

      await cartaoRef.update({
        'Valor_Fatura_Atual': novaFatura,
        'Data_Atualizacao': Timestamp.now(),
      });

      await doc.reference.update({'Processado': true});
    }
  }

  // Funções para adicionar ganhos e gastos
  Future<void> addGanhoPontual({
    required String nome,
    required double valor,
    required DateTime dataRecebimento,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final dataMap = {
      'Nome': nome,
      'Valor': valor,
      'Data_Recebimento': Timestamp.fromDate(dataRecebimento),
      'Recorrencia': false,
      'Deletado': false,
      'Data_Criacao': Timestamp.now(),
      'Data_Atualizacao': Timestamp.now(),
    };

    final ganhosRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('ganhos_fixos');

    await ganhosRef.add(dataMap);
  }

  Future<void> addGastoPontual({
    required String nome,
    required double valor,
    required String idTipoPagamento,
    required String idCategoria,
    String? idCartao,
    int parcelas = 1,
    required DateTime dataCompra,
    required bool recorrencia,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final gastoMap = {
      'Nome': nome,
      'Valor': valor,
      'ID_Tipo_Pagamento': idTipoPagamento,
      'ID_Cartao': idCartao,
      'ID_Categoria': idCategoria,
      'Parcelas': parcelas,
      'Data_Compra': Timestamp.fromDate(dataCompra),
      'Recorrencia': recorrencia,
      'Deletado': false,
      'Data_Criacao': Timestamp.now(),
      'Data_Atualizacao': Timestamp.now(),
    };

    final gastosRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('gastos_fixos');

    await gastosRef.add(gastoMap);
  }
}
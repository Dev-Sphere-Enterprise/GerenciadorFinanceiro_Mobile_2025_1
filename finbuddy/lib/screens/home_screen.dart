import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    processarParcelasPendentes();
    atualizarGanhosFixosVencidos();
    atualizarDatasCartoesVencidos();
    _checkNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Função principal para verificar todas as condições de notificação
  Future<void> _checkNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _checkAndNotifyMetas(user.uid);
    await _checkAndNotifyCardLimits(user.uid);
    await _checkAndNotifyGainsReceipt(user.uid);
    await _checkAndNotifyCardDueDates(user.uid);
  }

  // Verifica e notifica metas atingidas
  Future<void> _checkAndNotifyMetas(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final metasSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('metas')
        .where('Deletado', isEqualTo: false)
        .get();

    for (var doc in metasSnapshot.docs) {
      final data = doc.data();
      final valorAtual = (data['Valor_Atual'] ?? 0.0) as double;
      final valorObjetivo = (data['Valor_Objetivo'] ?? 0.0) as double;
      final nomeMeta = data['Nome'] ?? "Meta";

      if (valorAtual >= valorObjetivo) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode,
          'Parabéns!',
          'Você atingiu a meta: $nomeMeta',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'metas_channel',
              'Metas',
              channelDescription: 'Notificações sobre metas atingidas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkAndNotifyCardLimits(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final cartoesSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('cartoes')
        .where('Deletado', isEqualTo: false)
        .get();

    for (var doc in cartoesSnapshot.docs) {
      final data = doc.data();
      final valorFaturaAtual = (data['Valor_Fatura_Atual'] ?? 0.0) as double;
      final limiteCredito = (data['Limite_Credito'] ?? 0.0) as double;
      final nomeCartao = data['Nome'] ?? "Cartão";

      if (valorFaturaAtual >= limiteCredito) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 1000,
          'Atenção!',
          'Você atingiu o limite do cartão: $nomeCartao',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'cartoes_channel',
              'Cartões',
              channelDescription: 'Notificações sobre limite de cartões',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkAndNotifyGainsReceipt(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final ganhosSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('ganhos_fixos')
        .where('Deletado', isEqualTo: false)
        .get();

    final hoje = DateTime.now();
    final hojeSemTempo = DateTime(hoje.year, hoje.month, hoje.day);

    for (var doc in ganhosSnapshot.docs) {
      final data = doc.data();
      final Timestamp? ts = data['Data_Recebimento'];
      final nomeGanho = data['Nome'] ?? "Ganho";

      if (ts == null) continue;

      final dataRecebimento = ts.toDate();
      final dataRecebimentoSemTempo = DateTime(dataRecebimento.year, dataRecebimento.month, dataRecebimento.day);

      if (dataRecebimentoSemTempo.isAtSameMomentAs(hojeSemTempo)) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 2000, // ID único para a notificação
          'Lembrete de Ganho!',
          'Hoje é a data de recebimento do ganho: $nomeGanho',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'ganhos_channel',
              'Ganhos',
              channelDescription: 'Notificações sobre recebimento de ganhos',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  }

  // Verifica e notifica datas de fechamento ou vencimento de cartões
  Future<void> _checkAndNotifyCardDueDates(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final cartoesSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('cartoes')
        .where('Deletado', isEqualTo: false)
        .get();

    final hoje = DateTime.now();
    final hojeSemTempo = DateTime(hoje.year, hoje.month, hoje.day);

    for (var doc in cartoesSnapshot.docs) {
      final data = doc.data();
      final Timestamp? dataFechamentoTs = data['Data_Fechamento'];
      final Timestamp? dataVencimentoTs = data['Data_Vencimento'];
      final nomeCartao = data['Nome'] ?? "Cartão";

      if (dataFechamentoTs == null || dataVencimentoTs == null) continue;

      final dataFechamento = dataFechamentoTs.toDate();
      final dataVencimento = dataVencimentoTs.toDate();

      final dataFechamentoSemTempo = DateTime(dataFechamento.year, dataFechamento.month, dataFechamento.day);
      final dataVencimentoSemTempo = DateTime(dataVencimento.year, dataVencimento.month, dataVencimento.day);

      // Verifica se é a data de fechamento
      if (dataFechamentoSemTempo.isAtSameMomentAs(hojeSemTempo)) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 3000, // ID único para a notificação
          'Lembrete de Cartão!',
          'O cartão $nomeCartao fechou hoje. Verifique sua fatura!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'cartao_datas_channel',
              'Datas de Cartão',
              channelDescription: 'Notificações sobre datas de fechamento/vencimento de cartões',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
      // Verifica se é a data de vencimento
      else if (dataVencimentoSemTempo.isAtSameMomentAs(hojeSemTempo)) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 4000, // ID único para a notificação
          'Lembrete de Cartão!',
          'O cartão $nomeCartao vence hoje. Não se esqueça de pagar!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'cartao_datas_channel',
              'Datas de Cartão',
              channelDescription: 'Notificações sobre datas de fechamento/vencimento de cartões',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  }

  Future<void> atualizarGanhosFixosVencidos() async {
    final hoje = DateTime.now();
    final ganhosRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('ganhos_fixos');

    final snapshot = await ganhosRef
        .where('Deletado', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final dados = doc.data();
      final Timestamp? ts = dados['Data_Recebimento'];
      if (ts == null) continue;

      final dataRecebimento = ts.toDate();
      if (!dataRecebimento.isBefore(hoje) && !dataRecebimento.isAtSameMomentAs(hoje)) {
        continue; // ainda não chegou a data
      }

      final novaData = proximaDataMensal(dataRecebimento);
      await doc.reference.update({
        'Data_Recebimento': Timestamp.fromDate(novaData),
        'Data_Atualizacao': Timestamp.now(),
      });
    }
  }

  Future<void> atualizarDatasCartoesVencidos() async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final cartoesRef = firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('cartoes');

    final snapshot = await cartoesRef.where('Deletado', isEqualTo: false).get();

    final hoje = DateTime.now();

    for (var doc in snapshot.docs) {
      final dataVencimentoTimestamp = doc['Data_Vencimento'] as Timestamp?;
      final dataFechamentoTimestamp = doc['Data_Fechamento'] as Timestamp?;

      if (dataVencimentoTimestamp == null || dataFechamentoTimestamp == null) continue;

      final dataVencimento = dataVencimentoTimestamp.toDate();
      final dataFechamento = dataFechamentoTimestamp.toDate();

      if (!hoje.isBefore(dataVencimento)) {
        // Se hoje >= data vencimento, atualize ambas datas para o próximo mês
        final novaDataVencimento = proximaDataMensal(dataVencimento);
        final novaDataFechamento = proximaDataMensal(dataFechamento);

        await doc.reference.update({
          'Data_Vencimento': Timestamp.fromDate(novaDataVencimento),
          'Data_Fechamento': Timestamp.fromDate(novaDataFechamento),
          'Data_Atualizacao': Timestamp.now(),
        });
      }
    }
  }

  DateTime proximaDataMensal(DateTime dataOriginal) {
    final proximoMes = dataOriginal.month + 1;
    final ano = proximoMes > 12 ? dataOriginal.year + 1 : dataOriginal.year;
    final mes = proximoMes > 12 ? 1 : proximoMes;

    // Tentamos manter o mesmo dia, senão usamos o último dia do mês
    final ultimoDiaMes = DateTime(ano, mes + 1, 0).day;
    final dia = dataOriginal.day > ultimoDiaMes ? ultimoDiaMes : dataOriginal.day;

    return DateTime(ano, mes, dia);
  }

  Future<void> processarParcelasPendentes() async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;

    final hoje = Timestamp.fromDate(DateTime.now());

    final parcelas = await firestore
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

      final cartaoRef = firestore
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

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login realizado com sucesso!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'UID: ${user?.uid ?? "Desconhecido"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
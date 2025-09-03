import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class NotificationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Função principal para verificar todas as condições de notificação
  Future<void> checkNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _checkAndNotifyMetas(user.uid);
    await _checkAndNotifyCardLimits(user.uid);
    await _checkAndNotifyGainsReceipt(user.uid);
    await _checkAndNotifyCardDueDates(user.uid);
  }

  // Verifica e notifica metas atingidas
  Future<void> _checkAndNotifyMetas(String userId) async {
    final metasSnapshot = await _firestore
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

  // Verifica e notifica limites de cartões
  Future<void> _checkAndNotifyCardLimits(String userId) async {
    final cartoesSnapshot = await _firestore
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

  // Verifica e notifica sobre recebimento de ganhos
  Future<void> _checkAndNotifyGainsReceipt(String userId) async {
    final ganhosSnapshot = await _firestore
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
      final dataRecebimentoSemTempo =
      DateTime(dataRecebimento.year, dataRecebimento.month, dataRecebimento.day);

      if (dataRecebimentoSemTempo.isAtSameMomentAs(hojeSemTempo)) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 2000,
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

  // Verifica e notifica sobre datas de fechamento ou vencimento de cartões
  Future<void> _checkAndNotifyCardDueDates(String userId) async {
    final cartoesSnapshot = await _firestore
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

      final dataFechamentoSemTempo =
      DateTime(dataFechamento.year, dataFechamento.month, dataFechamento.day);
      final dataVencimentoSemTempo =
      DateTime(dataVencimento.year, dataVencimento.month, dataVencimento.day);

      if (dataFechamentoSemTempo.isAtSameMomentAs(hojeSemTempo)) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 3000,
          'Lembrete de Cartão!',
          'O cartão $nomeCartao fechou hoje. Verifique sua fatura!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'cartao_datas_channel',
              'Datas de Cartão',
              channelDescription:
              'Notificações sobre datas de fechamento/vencimento de cartões',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      } else if (dataVencimentoSemTempo.isAtSameMomentAs(hojeSemTempo)) {
        await flutterLocalNotificationsPlugin.show(
          doc.id.hashCode + 4000,
          'Lembrete de Cartão!',
          'O cartão $nomeCartao vence hoje. Não se esqueça de pagar!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'cartao_datas_channel',
              'Datas de Cartão',
              channelDescription:
              'Notificações sobre datas de fechamento/vencimento de cartões',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  }
}
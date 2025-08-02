import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<Map<DateTime, List<Map<String, dynamic>>>> carregarEventosCalendario({
  required FirebaseFirestore firestore,
  required FirebaseAuth auth,
}) async {
  final userId = auth.currentUser!.uid;

  final hoje = DateTime.now();
  final inicio = DateTime(hoje.year, hoje.month - 1, 1);
  final fim = DateTime(hoje.year, hoje.month + 2, 0);

  Map<DateTime, List<Map<String, dynamic>>> eventos = {};

  // Cartões
  final cartoesSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('cartoes')
      .where('Deletado', isEqualTo: false)
      .get();

  for (var doc in cartoesSnapshot.docs) {
    final fechamento = (doc['Data_Fechamento'] as Timestamp).toDate();
    final vencimento = (doc['Data_Vencimento'] as Timestamp).toDate();
    final valor = (doc['Valor_Fatura_Atual'] as num).toDouble();
    final valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

    void adicionarEvento(DateTime data, String label) {
      final date = DateTime(data.year, data.month, data.day);
      eventos.putIfAbsent(date, () => []).add({
        'tipo': 'cartao',
        'descricao': '${doc['Nome']} $label - Fatura: R\$ $valorFormatado',
      });
    }

    adicionarEvento(fechamento, '(Fechamento)');
    adicionarEvento(vencimento, '(Vencimento)');
  }

  // Gastos Fixos
  final gastosFixos = await firestore
      .collection('users')
      .doc(userId)
      .collection('gastos_fixos')
      .where('Deletado', isEqualTo: false)
      .where('Recorrencia', isEqualTo: true)
      .get();

  for (var doc in gastosFixos.docs) {
    final data = (doc['Data_Compra'] as Timestamp).toDate();
    final date = DateTime(data.year, data.month, data.day);
    final valor = (doc['Valor'] as num).toDouble();
    final valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

    eventos.putIfAbsent(date, () => []).add({
      'tipo': 'gasto',
      'descricao': '${doc['Nome']} - R\$ $valorFormatado',
    });
  }

  // Gastos Momentâneos
  final gastosMomentaneos = await firestore
      .collection('users')
      .doc(userId)
      .collection('gastos_fixos')
      .where('Deletado', isEqualTo: false)
      .where('Recorrencia', isEqualTo: false)
      .get();

  for (var doc in gastosMomentaneos.docs) {
    final data = (doc['Data_Compra'] as Timestamp).toDate();
    final date = DateTime(data.year, data.month, data.day);
    final horaFormatada = DateFormat('HH:mm').format(data);
    final valor = (doc['Valor'] as num).toDouble();
    final valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

    eventos.putIfAbsent(date, () => []).add({
      'tipo': 'gasto',
      'descricao': '${doc['Nome']} - R\$ $valorFormatado - $horaFormatada',
    });
  }

  // Ganhos Fixos
  final ganhosFixos = await firestore
      .collection('users')
      .doc(userId)
      .collection('ganhos_fixos')
      .where('Deletado', isEqualTo: false)
      .where('Recorrencia', isEqualTo: true)
      .get();

  for (var doc in ganhosFixos.docs) {
    final data = (doc['Data_Recebimento'] as Timestamp).toDate();
    final date = DateTime(data.year, data.month, data.day);
    final valor = (doc['Valor'] as num).toDouble();
    final valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

    eventos.putIfAbsent(date, () => []).add({
      'tipo': 'ganho',
      'descricao': '${doc['Nome']} - R\$ $valorFormatado',
    });
  }

  // Ganhos Momentâneos
  final ganhosMomentaneos = await firestore
      .collection('users')
      .doc(userId)
      .collection('ganhos_fixos')
      .where('Deletado', isEqualTo: false)
      .where('Recorrencia', isEqualTo: false)
      .get();

  for (var doc in ganhosMomentaneos.docs) {
    final data = (doc['Data_Recebimento'] as Timestamp).toDate();
    final date = DateTime(data.year, data.month, data.day);
    final horaFormatada = DateFormat('HH:mm').format(data);
    final valor = (doc['Valor'] as num).toDouble();
    final valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

    eventos.putIfAbsent(date, () => []).add({
      'tipo': 'ganho',
      'descricao': '${doc['Nome']} - R\$ $valorFormatado - $horaFormatada',
    });
  }

  return eventos;
}

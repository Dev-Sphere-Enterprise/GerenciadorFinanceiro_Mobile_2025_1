import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event_model.dart';
import '../models/cartao_model.dart'; 
import '../models/gasto_model.dart';
import '../models/ganho_model.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<CalendarEventModel>> carregarEventos() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    List<CalendarEventModel> todosEventos = [];

    final cartoesSnap = await _firestore.collection('users').doc(userId).collection('cartoes').where('Deletado', isEqualTo: false).get();
    for (var doc in cartoesSnap.docs) {
      final cartao = CartaoModel.fromMap(doc.id, doc.data());
      todosEventos.add(CalendarEventModel.withDefaultColor(descricao: '${cartao.nome} (Vencimento)', valor: cartao.valorFaturaAtual, tipo: EventType.cartao, data: cartao.dataVencimento));
      todosEventos.add(CalendarEventModel.withDefaultColor(descricao: '${cartao.nome} (Fechamento)', valor: 0, tipo: EventType.cartao, data: cartao.dataFechamento));
    }

    final gastosSnap = await _firestore.collection('users').doc(userId).collection('gastos_fixos').where('Deletado', isEqualTo: false).get();
    for (var doc in gastosSnap.docs) {
      final gasto = GastoModel.fromMap(doc.id, doc.data());
      todosEventos.add(CalendarEventModel.withDefaultColor(descricao: gasto.nome, valor: gasto.valor, tipo: EventType.gasto, data: gasto.dataCompra));
    }
    
    final ganhosSnap = await _firestore.collection('users').doc(userId).collection('ganhos_fixos').where('Deletado', isEqualTo: false).get();
    for (var doc in ganhosSnap.docs) {
      final ganho = GanhoModel.fromMap(doc.id, doc.data());
      todosEventos.add(CalendarEventModel.withDefaultColor(descricao: ganho.nome, valor: ganho.valor, tipo: EventType.ganho, data: ganho.dataRecebimento));
    }

    return todosEventos;
  }
}
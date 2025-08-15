import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'categoria_expense_data.dart';

Future<Map<String, CategoriaExpenseData>> carregarGastosPorCategoria(
  int ano,
  int mes,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return {};

  final inicioMes = DateTime(ano, mes, 1);
  final fimMes = DateTime(
    ano,
    mes + 1,
    1,
  ).subtract(const Duration(milliseconds: 1));

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('gastos_fixos')
      .get();

  final Map<String, CategoriaExpenseData> contagem = {};
  for (var doc in snapshot.docs) {
    final data = doc.data();

    if (data['Deletado'] == true) continue;

    final timestamp = data['Data_Compra'];
    if (timestamp == null || timestamp is! Timestamp) continue;

    final dataCompra = timestamp.toDate();
    if (dataCompra.isBefore(inicioMes) || dataCompra.isAfter(fimMes)) continue;

    final categoriaId = data['ID_Categoria'] ?? 'sem_categoria';
    final valor = (data['Valor'] ?? 0).toDouble();

    if (contagem.containsKey(categoriaId)) {
      contagem[categoriaId]!.count++;
      contagem[categoriaId]!.totalValue += valor;
    } else {
      contagem[categoriaId] = CategoriaExpenseData(count: 1, totalValue: valor);
    }
  }

  return contagem;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'helpers/gastos_fixos_helpers.dart';
import 'helpers/gastos_fixos_delete.dart';

class GastosFixosScreen extends StatefulWidget {
  const GastosFixosScreen({super.key});

  @override
  State<GastosFixosScreen> createState() => _GastosFixosScreenState();
}

class _GastosFixosScreenState extends State<GastosFixosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Fixos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('gastos_fixos')
            .where('Deletado', isEqualTo: false)
            .where('Recorrencia', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum gasto fixo cadastrado.'));
          }

          final gastos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              final id = gasto.id;
              final nome = gasto['Nome'] ?? '';
              final valor = gasto['Valor'] ?? 0.0;
              final dataCompra = (gasto['Data_Compra'] as Timestamp).toDate();
              final parcelas = gasto['Parcelas'] ?? 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Valor: R\$${valor.toStringAsFixed(2)}\nData: ${DateFormat('dd/MM/yyyy').format(dataCompra)}\nParcelas: $parcelas',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showAddOrEditGastoDialog(
                          context: context,
                          gastoId: id,
                          nome: nome,
                          valor: valor,
                          dataCompra: dataCompra,
                          parcelas: parcelas,
                          tipoPagamentoId: gasto['ID_Tipo_Pagamento'],
                          cartaoId: gasto['ID_Cartao'],
                          categoriaId: gasto['ID_Categoria'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteGasto(context, id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddOrEditGastoDialog(context: context),
        label: const Text('Adicionar Gasto'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

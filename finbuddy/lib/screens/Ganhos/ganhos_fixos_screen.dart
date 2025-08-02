import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'helpers/ganhos_fixos_dialog.dart';
import 'helpers/ganhos_fixos_service.dart';

class GanhosFixosScreen extends StatefulWidget {
  const GanhosFixosScreen({super.key});

  @override
  State<GanhosFixosScreen> createState() => _GanhosFixosScreenState();
}

class _GanhosFixosScreenState extends State<GanhosFixosScreen> {
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

    final ganhosRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('ganhos_fixos')
        .where('Deletado', isEqualTo: false)
        .where('Recorrencia', isEqualTo: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganhos Fixos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ganhosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum ganho cadastrado.'));
          }

          final ganhos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ganhos.length,
            itemBuilder: (context, index) {
              final ganho = ganhos[index];
              final id = ganho.id;
              final nome = ganho['Nome'] ?? '';
              final valor = ganho['Valor'] ?? 0.0;
              final dataRecebimento = ganho['Data_Recebimento'] != null
                  ? (ganho['Data_Recebimento'] as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Valor: R\$${valor.toStringAsFixed(2)}'
                        '${dataRecebimento != null ? "\nRecebimento: ${DateFormat('dd/MM').format(dataRecebimento)}" : ""}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showAddOrEditGanhoDialog(
                          context: context,
                          id: id,
                          nome: nome,
                          valor: valor.toDouble(),
                          data: dataRecebimento ?? DateTime.now(),
                          currentUser: currentUser!,
                          firestore: _firestore,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteGanho(
                          id: id,
                          currentUser: currentUser!,
                          firestore: _firestore,
                        ),
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
        onPressed: () => showAddOrEditGanhoDialog(
          context: context,
          currentUser: currentUser!,
          firestore: _firestore,
        ),
        label: const Text('Adicionar Ganho'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

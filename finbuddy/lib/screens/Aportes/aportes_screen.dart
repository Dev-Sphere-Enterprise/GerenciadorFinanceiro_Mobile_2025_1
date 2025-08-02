import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'helpers/add_edit_aporte_dialog.dart';
import 'helpers/delete_aporte.dart';
import 'helpers/atualizar_valor_meta.dart';

class TelaAportes extends StatefulWidget {
  final String metaId;
  final double valorAtual;

  const TelaAportes({super.key, required this.metaId, required this.valorAtual});

  @override
  State<TelaAportes> createState() => _TelaAportesState();
}

class _TelaAportesState extends State<TelaAportes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> _atualizarMeta() async {
    await atualizarValorMeta(
      firestore: _firestore,
      currentUser: currentUser!,
      metaId: widget.metaId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Usuário não autenticado')));
    }

    final aportesRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('metas')
        .doc(widget.metaId)
        .collection('aportes_meta')
        .where('Deletado', isEqualTo: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Aportes da Meta')),
      body: StreamBuilder<QuerySnapshot>(
        stream: aportesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Nenhum aporte cadastrado.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final aporte = docs[index];
              final valor = aporte['Valor'] ?? 0.0;
              final data = (aporte['Data_Aporte'] as Timestamp?)?.toDate();

              return Card(
                child: ListTile(
                  title: Text("R\$ ${valor.toStringAsFixed(2)}"),
                  subtitle: Text("Data: ${data != null ? DateFormat('dd/MM/yyyy').format(data) : '---'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showAddOrEditAporteDialog(
                          context: context,
                          firestore: _firestore,
                          currentUser: currentUser!,
                          metaId: widget.metaId,
                          atualizarValorMeta: _atualizarMeta,
                          id: aporte.id,
                          valor: valor.toDouble(),
                          data: data,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteAporte(
                          firestore: _firestore,
                          currentUser: currentUser!,
                          metaId: widget.metaId,
                          aporteId: aporte.id,
                          atualizarValorMeta: _atualizarMeta,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddOrEditAporteDialog(
          context: context,
          firestore: _firestore,
          currentUser: currentUser!,
          metaId: widget.metaId,
          atualizarValorMeta: _atualizarMeta,
        ),
        label: const Text('Novo Aporte'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

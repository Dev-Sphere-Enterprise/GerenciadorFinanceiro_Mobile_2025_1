import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Aportes/aportes_screen.dart';
import 'helpers/metas_helper.dart';
import 'helpers/metas_delete_helper.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final MetasHelper _helper = MetasHelper();

  User? get currentUser => _helper.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('metas')
            .where('Deletado', isEqualTo: false)
            .orderBy('Data_limite_meta')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Erro no snapshot: ${snapshot.error}');
            return const Center(child: Text('Erro ao carregar metas.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma meta cadastrada.'));
          }

          final metas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: metas.length,
            itemBuilder: (context, index) {
              final doc = metas[index];
              final nome = doc['Nome'] ?? '';
              final valorAtual = doc['Valor_Atual'] ?? 0.0;
              final valorObjetivo = doc['Valor_Objetivo'] ?? 0.0;
              final dataCriacao = (doc['Data_Criacao'] as Timestamp).toDate();
              final dataLimite = (doc['Data_limite_meta'] as Timestamp).toDate();

              return Card(
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Atual: R\$${valorAtual.toStringAsFixed(2)}\n'
                        'Objetivo: R\$${valorObjetivo.toStringAsFixed(2)}\n'
                        'Criado em: ${DateFormat('dd/MM/yyyy').format(dataCriacao)}\n'
                        'Limite: ${DateFormat('dd/MM/yyyy').format(dataLimite)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _helper.addOrEditMeta(
                          context: context,
                          id: doc.id,
                          nome: nome,
                          valorObjetivo: valorObjetivo,
                          dataLimite: dataLimite,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteMeta(doc.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_money, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaAportes(
                                metaId: doc.id,
                                valorAtual: valorAtual,
                              ),
                            ),
                          );
                        },
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
        onPressed: () => _helper.addOrEditMeta(context: context),
        label: const Text('Adicionar Meta'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

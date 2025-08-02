import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'helpers/add_edit_cartao_dialog.dart';
import 'helpers/delete_cartao.dart';

class CartoesScreen extends StatelessWidget {
  const CartoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Cartões'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('cartoes')
            .where('Deletado', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum cartão cadastrado.'));
          }

          final cartoes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartoes.length,
            itemBuilder: (context, index) {
              final cartao = cartoes[index];
              final id = cartao.id;
              final nome = cartao['Nome'] ?? '';
              final valorFatura = cartao['Valor_Fatura_Atual'] ?? 0.0;
              final limite = cartao['Limite_Credito'] ?? 0.0;
              final creditoDisponivel = cartao['Credito_Disponivel'] ?? 0.0;

              final dataFechamento = (cartao['Data_Fechamento'] as Timestamp?)?.toDate();
              final dataVencimento = (cartao['Data_Vencimento'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Fatura: R\$${valorFatura.toStringAsFixed(2)}\n'
                        'Crédito Total: R\$${limite.toStringAsFixed(2)}\n'
                        'Crédito Disponível: R\$${creditoDisponivel.toStringAsFixed(2)}\n'
                        'Fechamento: ${dataFechamento != null ? DateFormat('dd/MM').format(dataFechamento) : '-'}\n'
                        'Vencimento: ${dataVencimento != null ? DateFormat('dd/MM').format(dataVencimento) : '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showAddEditCartaoDialog(
                            context: context,
                            id: id,
                            nome: nome,
                            valorFatura: valorFatura.toDouble(),
                            limiteCredito: limite.toDouble(),
                            dataFechamento: dataFechamento,
                            dataVencimento: dataVencimento,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteCartao(context, id),
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
        onPressed: () => showAddEditCartaoDialog(context: context),
        label: const Text('Adicionar Cartão'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

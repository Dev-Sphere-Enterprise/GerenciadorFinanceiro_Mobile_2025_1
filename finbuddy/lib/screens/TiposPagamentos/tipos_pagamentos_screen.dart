import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'helpers/add_or_edit_tipo.dart';
import 'helpers/delete_tipo.dart';
import 'helpers/get_tipos_gerais.dart';
import 'helpers/get_tipos_usuario.dart';

class TiposPagamentosScreen extends StatefulWidget {
  const TiposPagamentosScreen({super.key});

  @override
  State<TiposPagamentosScreen> createState() => _TiposPagamentosScreenState();
}

class _TiposPagamentosScreenState extends State<TiposPagamentosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de Pagamentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: StreamZip([
          getTiposGerais(),
          getTiposUsuario(),
        ]).map((lists) => [...lists[0], ...lists[1]]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum tipo de pagamento disponível.'));
          }

          final tipos = snapshot.data!;

          return ListView.builder(
            itemCount: tipos.length,
            itemBuilder: (context, index) {
              final tipo = tipos[index];
              final id = tipo['id'];
              final nome = tipo['Nome'];
              final parcelavel = tipo['Parcelavel'] ?? false;
              final isGeneral = tipo['isGeneral'] ?? false;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Parcelável: ${parcelavel ? "Sim" : "Não"} | Usa Cartão: ${tipo['UsaCartao'] == true ? "Sim" : "Não"}',
                  ),
                  trailing: isGeneral
                      ? null
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => addOrEditTipo(
                          context: context,
                          id: id,
                          nome: nome,
                          parcelavel: parcelavel,
                          usaCartao: tipo['UsaCartao'] ?? false,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTipo(id),
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
        onPressed: () => addOrEditTipo(context: context),
        label: const Text('Adicionar Tipo de Pagamento'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'helpers/categoria_dialog.dart';
import 'helpers/delete_categoria.dart';
import 'helpers/get_categorias_gerais.dart';
import 'helpers/get_categorias_usuario.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}
class _CategoriasScreenState extends State<CategoriasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: StreamZip([
          getCategoriasGerais(),
          getCategoriasUsuario(),
        ]).map((lists) => [...lists[0], ...lists[1]]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma categoria disponível.'));
          }

          final categorias = snapshot.data!;

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final id = categoria['id'];
              final nome = categoria['Nome'];
              final isGeneral = categoria['isGeneral'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(nome),
                  trailing: isGeneral
                      ? null
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await showCategoriaDialog(context, id: id, nome: nome);
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await deleteCategoria(id);
                          setState(() {});
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
        onPressed: () => showCategoriaDialog(context),
        label: const Text('Adicionar Categoria'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

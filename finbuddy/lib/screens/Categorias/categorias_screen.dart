import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'helpers/categoria_dialog.dart';
import 'helpers/delete_categoria.dart';
import 'helpers/get_categorias_gerais.dart';
import 'helpers/get_categorias_usuario.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0xFFFAF3DD);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark, 
);

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  Future<void> _confirmDelete(String id, String nome) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja remover a categoria "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteCategoria(id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoScaffold,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: finBuddyLime, 
        title: Text(
          'Fin_Buddy',
          style: estiloFonteMonospace.copyWith(
            color: finBuddyBlue, 
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue), 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: corCardPrincipal,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Categorias',
                  textAlign: TextAlign.center,
                  style: estiloFonteMonospace.copyWith(
                    fontSize: 24,
                    color: finBuddyDark, 
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: StreamZip([
                      getCategoriasGerais(),
                      getCategoriasUsuario(),
                    ]).map((lists) => [...lists[0], ...lists[1]]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhuma categoria disponível.',
                            style: estiloFonteMonospace,
                          ),
                        );
                      }
                      final categorias = snapshot.data!;
                      return ListView.builder(
                        itemCount: categorias.length,
                        itemBuilder: (context, index) {
                          final categoria = categorias[index];
                          final id = categoria['id'];
                          final nome = categoria['Nome'];
                          final isGeneral = categoria['isGeneral'] ?? false;
                          
                          return _buildCategoriaItem(id, nome, isGeneral);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finBuddyLime, 
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await showCategoriaDialog(context);
                    setState(() {});
                  },
                  child: Text(
                    'Adicionar',
                    style: estiloFonteMonospace.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaItem(String id, String nome, bool isGeneral) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: finBuddyLime, 
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                nome,
                textAlign: TextAlign.center,
                style: estiloFonteMonospace.copyWith(fontSize: 16),
              ),
            ),
          ),
          if (!isGeneral)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: finBuddyDark), 
                  onPressed: () async {
                    await showCategoriaDialog(context, id: id, nome: nome);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: finBuddyDark), 
                  onPressed: () => _confirmDelete(id, nome),
                ),
              ],
            )
          else
            const SizedBox(width: 96),
        ],
      ),
    );
  }
}
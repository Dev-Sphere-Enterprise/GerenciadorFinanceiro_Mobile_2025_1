import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/categoria_model.dart';
import 'dialog/categoria_dialog.dart';
import 'viewmodel/categorias_viewmodel.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriasViewModel(),
      child: Scaffold(
        backgroundColor: corFundoScaffold,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: finBuddyLime,
          title: Text('Fin_Buddy', style: estiloFonteMonospace.copyWith(color: finBuddyBlue, fontSize: 22)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<CategoriasViewModel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(color: corCardPrincipal, borderRadius: BorderRadius.circular(12.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Categorias', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 24, color: finBuddyDark)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<List<CategoriaModel>>(
                          stream: viewModel.categoriasStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('Nenhuma categoria disponível.', style: estiloFonteMonospace));
                            }
                            final categorias = snapshot.data!;
                            return ListView.builder(
                              itemCount: categorias.length,
                              itemBuilder: (context, index) {
                                return _buildCategoriaItem(context, viewModel, categorias[index]);
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => showCategoriaDialog(context),
                        child: Text('Adicionar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriaItem(BuildContext context, CategoriasViewModel viewModel, CategoriaModel categoria) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(color: corItem, borderRadius: BorderRadius.circular(8.0)),
              child: Text(categoria.nome, textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 16)),
            ),
          ),
          SizedBox(
            width: 96,
            child: !categoria.isGeneral
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                        onPressed: () => showCategoriaDialog(context, categoria: categoria),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                  title: const Text("Confirmar exclusão"),
                                  content: Text("Você tem certeza que deseja deletar a categoria '${categoria.nome}'?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deletar", style: TextStyle(color: Colors.red))),
                                  ]));
                          if (confirm == true) {
                            await viewModel.excluirCategoria(categoria.id!);
                          }
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/categoria_model.dart';
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
                                return _buildCategoriaItem(context, categorias[index]);
                              },
                            );
                          },
                        ),
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

  Widget _buildCategoriaItem(BuildContext context, CategoriaModel categoria) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: corItem, borderRadius: BorderRadius.circular(8.0)),
        child: Text(
          categoria.nome,
          textAlign: TextAlign.center,
          style: estiloFonteMonospace.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}

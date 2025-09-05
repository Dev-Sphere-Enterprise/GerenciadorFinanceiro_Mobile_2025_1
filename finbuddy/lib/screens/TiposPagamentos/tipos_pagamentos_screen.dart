import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/tipo_pagamento_model.dart';
import 'dialog/add_or_edit_tipo.dart';
import 'viewmodel/tipos_pagamento_viewmodel.dart';

class TiposPagamentosScreen extends StatelessWidget {
  const TiposPagamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TiposPagamentoViewModel()..loadTiposGerais(),
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
        body: Consumer<TiposPagamentoViewModel>(
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
                      Text(
                        'Tipos de Pagamento',
                        textAlign: TextAlign.center,
                        style: estiloFonteMonospace.copyWith(fontSize: 24, color: finBuddyDark),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<List<TipoPagamentoModel>>(
                          stream: viewModel.tiposCombinadosStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Erro ao carregar os dados.', style: estiloFonteMonospace));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('Nenhum tipo disponível.', style: estiloFonteMonospace));
                            }

                            final tipos = snapshot.data!;
                            return ListView.builder(
                              itemCount: tipos.length,
                              itemBuilder: (context, index) => _buildTipoItem(context, viewModel, tipos[index]),
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
                        onPressed: () => showAddOrEditTipoDialog(context: context),
                        child: Text("Adicionar", style: estiloFonteMonospace.copyWith(fontSize: 16)),
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

  Widget _buildTipoItem(BuildContext context, TiposPagamentoViewModel viewModel, TipoPagamentoModel tipo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(color: corItem, borderRadius: BorderRadius.circular(8.0)),
              child: Text(tipo.nome, textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 16)),
            ),
          ),
          SizedBox(
            width: 96,
            child: !tipo.isFixo
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                  onPressed: () => showAddOrEditTipoDialog(context: context, tipo: tipo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: const Text("Confirmar exclusão"),
                            content: Text("Deseja deletar o tipo '${tipo.nome}'?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deletar", style: TextStyle(color: Colors.red))),
                            ]));
                    if (confirm == true && context.mounted) {
                      await Provider.of<TiposPagamentoViewModel>(context, listen: false).excluirTipo(tipo.id!);
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
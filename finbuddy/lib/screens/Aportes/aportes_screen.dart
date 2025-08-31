import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../shared/core/models/aporte_meta_model.dart';
import 'viewmodel/aportes_viewmodel.dart';
import 'helpers/add_edit_aporte_dialog.dart';

class TelaAportes extends StatelessWidget {
  final String metaId;

  const TelaAportes({super.key, required this.metaId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AportesViewModel(metaId: metaId),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Aportes da Meta'),
        ),
        body: Consumer<AportesViewModel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<AporteMetaModel>>(
                      stream: viewModel.aportesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Nenhum aporte cadastrado.'));
                        }

                        final aportes = snapshot.data!;
                        return ListView.builder(
                          itemCount: aportes.length,
                          itemBuilder: (context, index) {
                            return _buildAporteItem(context, viewModel, aportes[index]);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () => showAddOrEditAporteDialog(context: context),
                      child: const Text('Adicionar Aporte'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAporteItem(BuildContext context, AportesViewModel viewModel, AporteMetaModel aporte) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

    return ListTile(
      title: Text(formatadorMoeda.format(aporte.valor)),
      subtitle: Text(formatadorData.format(aporte.dataAporte)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showAddOrEditAporteDialog(
              context: context,
              aporte: aporte,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context, 
                builder: (context) => AlertDialog( 
                  title: const Text("Confirmar exclusão"),
                  content: const Text("Você tem certeza que deseja deletar este aporte?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      child: const Text("Deletar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await viewModel.excluirAporte(aporte.id!); 
              }
            },
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/aporte_meta_model.dart';
import '../../shared/core/repositories/aportes_repository.dart';
import 'viewmodel/aportes_viewmodel.dart';
import 'dialog/add_edit_aporte_dialog.dart';

class TelaAportes extends StatelessWidget {
  final String metaId;

  const TelaAportes({super.key, required this.metaId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repository = Provider.of<AportesRepository>(context, listen: false);
        return AportesViewModel(metaId: metaId, repository: repository);
      },
      child: Scaffold(
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
        body: Consumer<AportesViewModel>(
          builder: (context, viewModel, child) {
            return SafeArea(
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
                        'Aportes da Meta',
                        textAlign: TextAlign.center,
                        style: estiloFonteMonospace.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<List<AporteMetaModel>>(
                          stream: viewModel.aportesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Nenhum aporte cadastrado.',
                                      style: estiloFonteMonospace));
                            }

                            final aportes = snapshot.data!;
                            return ListView.builder(
                              itemCount: aportes.length,
                              itemBuilder: (context, index) {
                                return _buildAporteItem(
                                    context, viewModel, aportes[index]);
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
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () =>
                            showAddOrEditAporteDialog(context: context),
                        child: Text('Adicionar Aporte',
                            style:
                                estiloFonteMonospace.copyWith(fontSize: 16)),
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

  Widget _buildAporteItem(BuildContext context, AportesViewModel viewModel, AporteMetaModel aporte) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: corItemGasto, 
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor: ${formatadorMoeda.format(aporte.valor)}',
                    style: estiloFonteMonospace.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data: ${formatadorData.format(aporte.dataAporte)}',
                    style: estiloFonteMonospace.copyWith(
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () => showAddOrEditAporteDialog(
                  context: context,
                  aporte: aporte,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar exclusão"),
                      content: const Text(
                          "Você tem certeza que deseja deletar este aporte?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Deletar",
                              style: TextStyle(color: Colors.red)),
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
        ],
      ),
    );
  }
}
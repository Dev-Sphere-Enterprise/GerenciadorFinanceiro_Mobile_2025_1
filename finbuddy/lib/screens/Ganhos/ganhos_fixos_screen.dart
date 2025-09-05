import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/ganho_model.dart';
import 'dialog/ganhos_fixos_dialog.dart';
import 'viewmodel/ganhos_viewmodel.dart';

class GanhosFixosScreen extends StatelessWidget {
  const GanhosFixosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Consumer<GanhosViewModel>(
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
                    Text('Ganhos Fixos', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 24)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<List<GanhoModel>>(
                        stream: viewModel.ganhosStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            debugPrint(snapshot.error.toString());
                            return const Center(child: Text('Ocorreu um erro. Verifique o console.'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Nenhum ganho cadastrado.', style: estiloFonteMonospace));
                          }
                          final ganhos = snapshot.data!;
                          return ListView.builder(
                            itemCount: ganhos.length,
                            itemBuilder: (context, index) {
                              return _buildGanhoItem(context, viewModel, ganhos[index]);
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
                      onPressed: () => showAddOrEditGanhoDialog(context: context),
                      child: Text('Adicionar Ganho', style: estiloFonteMonospace.copyWith(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGanhoItem(BuildContext context, GanhosViewModel viewModel, GanhoModel ganho) {
    // ... NENHUMA MUDANÇA NECESSÁRIA AQUI ...
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: corItemGasto, borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ganho.nome, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Valor: ${formatadorMoeda.format(ganho.valor)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                  Text('Recebimento: Dia ${formatadorData.format(ganho.dataRecebimento)} de cada mês', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () => showAddOrEditGanhoDialog(context: context, ganho: ganho),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text("Confirmar exclusão"),
                          content: const Text("Você tem certeza que deseja deletar este ganho?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deletar", style: TextStyle(color: Colors.red))),
                          ]));
                  if (confirm == true) {
                    await viewModel.excluirGanho(ganho.id!);
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
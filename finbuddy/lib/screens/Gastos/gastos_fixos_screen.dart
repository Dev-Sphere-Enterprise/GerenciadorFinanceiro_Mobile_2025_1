// lib/screens/Gastos/gastos_fixos_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../../../shared/core/models/gasto_model.dart';
import 'dialog/gastos_fixos_dialog.dart';
import 'viewmodel/gastos_viewmodel.dart';

class GastosFixosScreen extends StatelessWidget {
  const GastosFixosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GastosViewModel(),
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
        body: Consumer<GastosViewModel>(
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
                      Text('Gastos Fixos', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 24)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<List<GastoModel>>(
                          stream: viewModel.gastosStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                            if (snapshot.hasError) return const Center(child: Text('Erro ao carregar dados.'));
                            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Nenhum gasto fixo cadastrado.', style: estiloFonteMonospace));

                            final gastos = snapshot.data!;
                            return ListView.builder(
                              itemCount: gastos.length,
                              itemBuilder: (context, index) => _buildGastoItem(context, viewModel, gastos[index]),
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
                        onPressed: viewModel.isDialogLoading ? null : () async {
                          await viewModel.loadDialogDependencies();
                          if (context.mounted) {
                            showAddOrEditGastoDialog(context: context);
                          }
                        },
                        child: viewModel.isDialogLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : Text('Adicionar', style: estiloFonteMonospace.copyWith(fontSize: 16)),
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

  Widget _buildGastoItem(BuildContext context, GastosViewModel viewModel, GastoModel gasto) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

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
                  Text(gasto.nome, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Valor: ${formatadorMoeda.format(gasto.valor)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                  Text('Data: ${formatadorData.format(gasto.dataCompra)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: viewModel.isDialogLoading ? null : () async {
                  await viewModel.loadDialogDependencies();
                  if(context.mounted) {
                    showAddOrEditGastoDialog(context: context, gasto: gasto);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text("Confirmar exclusão"),
                          content: Text("Deseja deletar o gasto '${gasto.nome}'?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deletar", style: TextStyle(color: Colors.red))),
                          ]));
                  if (confirm == true && context.mounted) {
                    await Provider.of<GastosViewModel>(context, listen: false).excluirGasto(gasto.id!);
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
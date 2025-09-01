import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/meta_model.dart';
import '../Aportes/aportes_screen.dart';
import 'helpers/add_edit_meta_dialog.dart';
import 'viewmodel/metas_viewmodel.dart';

class MetasScreen extends StatelessWidget {
  const MetasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MetasViewModel(),
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
        body: Consumer<MetasViewModel>(
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
                      Text('Minhas Metas', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 24)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<List<MetaModel>>(
                          stream: viewModel.metasStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                            if (snapshot.hasError) return const Center(child: Text('Erro ao carregar metas.'));
                            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Nenhuma meta cadastrada.', style: estiloFonteMonospace));
                            
                            final metas = snapshot.data!;
                            return ListView.builder(
                              itemCount: metas.length,
                              itemBuilder: (context, index) => _buildMetaItem(context, viewModel, metas[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: finBuddyLime, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => showAddOrEditMetaDialog(context: context),
                        child: Text('Adicionar Meta', style: estiloFonteMonospace.copyWith(fontSize: 16)),
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

  Widget _buildMetaItem(BuildContext context, MetasViewModel viewModel, MetaModel meta) {
    final progresso = meta.valorObjetivo > 0 ? (meta.valorAtual / meta.valorObjetivo).clamp(0.0, 1.0) : 0.0;
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: corItemMeta, borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.nome, style: estiloFonteMonospace.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('${formatadorMoeda.format(meta.valorAtual)} de ${formatadorMoeda.format(meta.valorObjetivo)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 14)),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progresso, minHeight: 10, backgroundColor: Colors.black12, color: finBuddyBlue)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progresso * 100).toStringAsFixed(0)}% Completo', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12)),
                      Text('Limite: ${formatadorData.format(meta.dataLimiteMeta)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.attach_money, color: finBuddyDark), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TelaAportes(metaId: meta.id!)))),
              IconButton(icon: const Icon(Icons.edit_outlined, color: finBuddyDark), onPressed: () => showAddOrEditMetaDialog(context: context, meta: meta)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text("Confirmar exclusão"),
                          content: const Text("Você tem certeza que deseja deletar esta meta?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deletar", style: TextStyle(color: Colors.red))),
                          ]));
                  if (confirm == true) {
                    await viewModel.excluirMeta(meta.id!);
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
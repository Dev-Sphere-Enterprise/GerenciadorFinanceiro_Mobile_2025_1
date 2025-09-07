import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/cartao_model.dart';
import 'viewmodel/cartoes_viewmodel.dart';
import 'dialog/add_edit_cartao_dialog.dart';

class CartoesScreen extends StatelessWidget {
  const CartoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O ChangeNotifierProvider foi removido. A tela agora retorna o Scaffold diretamente.
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
      // O Consumer continua funcionando perfeitamente, pois ele busca o ViewModel
      // na árvore de widgets acima dele.
      body: Consumer<CartoesViewModel>(
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
                    Text('Meus Cartões', textAlign: TextAlign.center, style: estiloFonteMonospace.copyWith(fontSize: 24)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<List<CartaoModel>>(
                        stream: viewModel.cartoesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Nenhum cartão cadastrado.', style: estiloFonteMonospace));
                          }
                          final cartoes = snapshot.data!;
                          return ListView.builder(
                            itemCount: cartoes.length,
                            itemBuilder: (context, index) {
                              return _buildCartaoItem(context, viewModel, cartoes[index]);
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
                      onPressed: () => showAddEditCartaoDialog(context: context),
                      child: Text('Adicionar Cartão', style: estiloFonteMonospace.copyWith(fontSize: 16)),
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

  // Nenhuma alteração necessária nos métodos auxiliares
  Widget _buildCartaoItem(BuildContext context, CartoesViewModel viewModel, CartaoModel cartao) {
    final progresso = cartao.limiteCredito > 0 ? (cartao.valorFaturaAtual / cartao.limiteCredito).clamp(0.0, 1.0) : 0.0;
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12.0),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartao.nome, style: estiloFonteMonospace.copyWith(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text('Fatura: ${formatadorMoeda.format(cartao.valorFaturaAtual)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progresso, minHeight: 8, backgroundColor: Colors.black26, color: finBuddyLime)),
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerRight, child: Text('Limite: ${formatadorMoeda.format(cartao.limiteCredito)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white70))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fechamento: ${formatadorData.format(cartao.dataFechamento)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white70)),
                      Text('Vencimento: ${formatadorData.format(cartao.dataVencimento)}', style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white70)),
                    ],
                  )
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: finBuddyDark),
                onPressed: () => showAddEditCartaoDialog(context: context, cartao: cartao),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: finBuddyDark),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text("Confirmar exclusão"),
                          content: const Text("Você tem certeza que deseja deletar este Cartão?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deletar", style: TextStyle(color: Colors.red))),
                          ]));
                  if (confirm == true) {
                    await viewModel.excluirCartao(cartao.id!);
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
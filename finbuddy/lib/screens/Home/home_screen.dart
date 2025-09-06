import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/style_constants.dart';
import '../Calendar/calendar_screen.dart';
import '../Gastos/dialog/gastos_fixos_dialog.dart';
import '../Ganhos/dialog/ganhos_fixos_dialog.dart';
import '../GraficoDeGastos/widgets/grafico_de_gastos_widget.dart';
import '../Profile/profile_screen.dart';
import '../Gastos/viewmodel/gastos_viewmodel.dart';
import '../Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'viewmodel/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.pendingAction != null) {
            if (viewModel.pendingAction == 'add_gain') {
              _onAddGanhoPressed(context);
            }
            if (viewModel.pendingAction == 'add_expense') {
              _onAddGastoPressed(context);
            }
            viewModel.clearPendingAction();
          }
        });

        return Scaffold(
          backgroundColor: corFundoScaffold,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddOptions(context),
            backgroundColor: finBuddyBlue,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: finBuddyDark))
              : Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildBalanceCard(context, viewModel),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GraficoDeGastosWidget(limiteCategorias: 3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.green),
            title: const Text('Adicionar Ganho'),
            onTap: () {
              Navigator.of(ctx).pop();
              _onAddGanhoPressed(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_down, color: Colors.red),
            title: const Text('Adicionar Gasto'),
            onTap: () {
              Navigator.of(ctx).pop();
              _onAddGastoPressed(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onAddGanhoPressed(BuildContext context) async {
      await showAddOrEditGanhoDialog(context: context);
      Provider.of<HomeViewModel>(context, listen: false).refreshBalance();
  }

  Future<void> _onAddGastoPressed(BuildContext context) async {
    final gastosViewModel = Provider.of<GastosViewModel>(context, listen: false);
    await gastosViewModel.loadDialogDependencies();
    if (context.mounted) {
      await showAddOrEditGastoDialog(context: context);
      Provider.of<HomeViewModel>(context, listen: false).refreshBalance();
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: finBuddyLime,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: finBuddyBlue, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
          Text(
            'Fin_Buddy',
            style: estiloFonteMonospace.copyWith(color: finBuddyBlue, fontSize: 22),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: finBuddyBlue, size: 32),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, HomeViewModel viewModel) {
    final saldo = viewModel.balanceData['saldo'] ?? 0.0;
    final gastos = viewModel.balanceData['gastos'] ?? 0.0;
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: corCardSaldo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo atual: ${viewModel.isBalanceVisibleSaldo ? formatador.format(saldo) : "R\$ ---"}',
                style: estiloFonteMonospace.copyWith(fontSize: 16),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(viewModel.isBalanceVisibleSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: finBuddyDark),
                onPressed: viewModel.toggleSaldoVisibility,
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos do mês: ${viewModel.isBalanceVisibleGasto ? formatador.format(gastos) : "R\$ ---"}',
                style: estiloFonteMonospace.copyWith(fontSize: 16),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(viewModel.isBalanceVisibleGasto ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: finBuddyDark),
                onPressed: viewModel.toggleGastosVisibility,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
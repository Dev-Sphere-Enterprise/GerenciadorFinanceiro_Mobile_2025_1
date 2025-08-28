import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Profile/profile_screen.dart';
import '../Calendar/calendar_screen.dart';
import 'helpers/notification_service.dart';
import 'helpers/transaction_service.dart';
import 'helpers/add_gain_dialog.dart';
import 'helpers/add_expense_dialog.dart';
import '../GraficoDeGastos/widgets/grafico_de_gastos_widget.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0x8BFAF3DD);
const Color corCardSaldo = Color(0x89B9CD67);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final TransactionService _transactionService = TransactionService();

  bool _isBalanceVisibleSaldo = false;
  bool _isBalanceVisibleGasto = false;
  late Future<Map<String, double>> _balanceData;

  @override
  void initState() {
    super.initState();
    _balanceData = _fetchBalanceData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingAction();
    });
    _initAndCheckServices();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<double> getGastosTotais() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return 0.0;
    }

    final gastosSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('gastos_fixos')
        .where('Deletado', isEqualTo: false)
        .get();

    double totalGasto = 0.0;
    for (var doc in gastosSnapshot.docs) {
      // Correção: Converte o valor para double com segurança
      totalGasto += (doc.data()['Valor'] as num).toDouble();
    }

    return totalGasto;
  }

  Future<double> getSaldo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return 0.0;
    }

    final ganhosSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('ganhos_fixos')
        .where('Deletado', isEqualTo: false)
        .get();

    double totalGanho = 0.0;
    for (var doc in ganhosSnapshot.docs) {
      // Correção: Converte o valor para double com segurança
      totalGanho += (doc.data()['Valor'] as num).toDouble();
    }

    return totalGanho;
  }

  Future<double> getGasto() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return 0.0;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final gastosSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('gastos_fixos')
        .where('Data_Compra', isGreaterThanOrEqualTo: startOfMonth)
        .where('Data_Compra', isLessThanOrEqualTo: endOfMonth)
        .where('Deletado', isEqualTo: false)
        .get();

    double totalGasto = 0.0;
    for (var doc in gastosSnapshot.docs) {
      // Correção: Converte o valor para double com segurança
      totalGasto += (doc.data()['Valor'] as num).toDouble();
    }

    return totalGasto;
  }

  Future<Map<String, double>> _fetchBalanceData() async {
    final totalGanho = await getSaldo();
    final totalGasto = await getGasto();
    final totalGastosTotais = await getGastosTotais();

    final saldoFinal = totalGanho - totalGastosTotais;

    return {
      'saldo': saldoFinal,
      'gastos': totalGasto,
    };
  }

  Future<void> _checkPendingAction() async {
    final prefs = await SharedPreferences.getInstance();
    final action = prefs.getString('pending_action') ?? '';
    if (action.isNotEmpty) {
      prefs.remove('pending_action');
      if (action == 'add_gain') showAddGainDialog(context);
      else if (action == 'add_expense') showAddExpenseDialog(context);
    }
  }

  Future<void> _initAndCheckServices() async {
    await _notificationService.initNotifications();
    await _transactionService.processarParcelasPendentes();
    await _transactionService.atualizarGanhosFixosVencidos();
    await _transactionService.atualizarDatasCartoesVencidos();
    await _notificationService.checkNotifications();
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Adicionar Ganho'),
              onTap: () { Navigator.of(ctx).pop(); showAddGainDialog(context); },
            ),
            ListTile(
              leading: const Icon(Icons.trending_down, color: Colors.red),
              title: const Text('Adicionar Gasto'),
              onTap: () { Navigator.of(ctx).pop(); showAddExpenseDialog(context); },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
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

  Widget _buildBalanceCard() {
    return FutureBuilder<Map<String, double>>(
      future: _balanceData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 60, child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar saldo', style: estiloFonteMonospace));
        }
        
        final saldo = snapshot.data?['saldo'] ?? 0.0;
        final gastos = snapshot.data?['gastos'] ?? 0.0;

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
                    'Saldo atual: ${_isBalanceVisibleSaldo ? "R\$ ${saldo.toStringAsFixed(2)}" : "R\$ ---"}',
                    style: estiloFonteMonospace.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(_isBalanceVisibleSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: finBuddyDark),
                    onPressed: () => setState(() => _isBalanceVisibleSaldo = !_isBalanceVisibleSaldo),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gastos do mês: ${_isBalanceVisibleGasto ? "R\$ ${gastos.toStringAsFixed(2)}" : "R\$ ---"}',
                    style: estiloFonteMonospace.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _isBalanceVisibleGasto
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: finBuddyDark,
                    ),
                    onPressed: () => setState(
                          () => _isBalanceVisibleGasto = !_isBalanceVisibleGasto,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoScaffold,
      resizeToAvoidBottomInset: false, 
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: finBuddyBlue,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBalanceCard(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: corCardPrincipal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SingleChildScrollView(
                  child: GraficoDeGastosWidget(limiteCategorias: 3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
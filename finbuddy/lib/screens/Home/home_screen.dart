import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
const Color corCardPrincipal = Color(0xFFFAF3DD);
const Color corCardSaldo = Color(0xFFE0D8B3);

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

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isBalanceVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingAction();
    });
    _initAndCheckServices();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Widget _buildHeader() {
    return Container(
      color: finBuddyLime,
      padding: const EdgeInsets.only(top: 40, bottom: 10, left: 16, right: 16),
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
                'Saldo atual: ${_isBalanceVisible ? "R\$ 1.500,00" : "R\$ ---"}',
                style: estiloFonteMonospace.copyWith(fontSize: 16),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(_isBalanceVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: finBuddyDark),
                onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Gastos do mês: R\$ 50,00',
            style: estiloFonteMonospace.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? finBuddyDark : Colors.grey,
          ),
        );
      }),
    );
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
              onTap: () {
                Navigator.of(ctx).pop();
                showAddGainDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_down, color: Colors.red),
              title: const Text('Adicionar Gasto'),
              onTap: () {
                Navigator.of(ctx).pop();
                showAddExpenseDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoScaffold,
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
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          const GraficoDeGastosWidget(limiteCategorias: 3),

                          const Center(child: Text('Placeholder para Gráfico de Linhas', style: estiloFonteMonospace)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPageIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
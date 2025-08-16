import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Profile/profile_screen.dart';
import '../Calendar/calendar_screen.dart';
import 'helpers/notification_service.dart';
import 'helpers/transaction_service.dart';
import 'helpers/add_gain_dialog.dart';
import 'helpers/add_expense_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../GraficoDeGastos/widgets/grafico_de_gastos_widget.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingAction();
    });
    _initAndCheckServices();
  }

  Future<void> _checkPendingAction() async {
    final prefs = await SharedPreferences.getInstance();
    final action = prefs.getString('pending_action') ?? '';

    if (action.isNotEmpty) {
      prefs.remove('pending_action');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (action == 'add_gain') {
          showAddGainDialog(context);
        } else if (action == 'add_expense') {
          showAddExpenseDialog(context);
        }
      });
    }
  }

  Future<void> _initAndCheckServices() async {
    await _notificationService.initNotifications();
    await _transactionService.processarParcelasPendentes();
    await _transactionService.atualizarGanhosFixosVencidos();
    await _transactionService.atualizarDatasCartoesVencidos();
    await _notificationService.checkNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.white,
        overlayColor: Colors.black12,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.trending_up),
            label: 'Adicionar Ganho',
            backgroundColor: Colors.blue,
            onTap: () => showAddGainDialog(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.trending_down),
            label: 'Adicionar Gasto',
            backgroundColor: Colors.red,
            onTap: () => showAddExpenseDialog(context),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const GraficoDeGastosWidget(limiteCategorias: 3),
                ),
              ),

              const SizedBox(height: 20),


            ],
          ),
        ),
      ),
    );
  }
}
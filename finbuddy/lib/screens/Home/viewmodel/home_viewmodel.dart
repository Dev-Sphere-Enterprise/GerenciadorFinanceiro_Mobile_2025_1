import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/core/repositories/dashboard_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, double> _balanceData = {'saldo': 0.0, 'gastos': 0.0};
  Map<String, double> get balanceData => _balanceData;
  
  String? _pendingAction;
  String? get pendingAction => _pendingAction;

  bool _isBalanceVisibleSaldo = false;
  bool get isBalanceVisibleSaldo => _isBalanceVisibleSaldo;

  bool _isBalanceVisibleGasto = false;
  bool get isBalanceVisibleGasto => _isBalanceVisibleGasto;

  HomeViewModel() {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _repository.runStartupTasks(),
      _repository.getBalanceData(),
      _checkPendingAction(),
    ]);

    _balanceData = results[1] as Map<String, double>;
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkPendingAction() async {
    final prefs = await SharedPreferences.getInstance();
    _pendingAction = prefs.getString('pending_action');
    if (_pendingAction != null) {
      prefs.remove('pending_action');
    }
  }
  
  void clearPendingAction() {
      _pendingAction = null;
  }

  void toggleSaldoVisibility() {
    _isBalanceVisibleSaldo = !_isBalanceVisibleSaldo;
    notifyListeners();
  }

  void toggleGastosVisibility() {
    _isBalanceVisibleGasto = !_isBalanceVisibleGasto;
    notifyListeners();
  }
  
  void refreshBalance() async {
      _balanceData = await _repository.getBalanceData();
      notifyListeners();
  }
}
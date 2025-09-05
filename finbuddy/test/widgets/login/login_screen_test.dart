import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'package:finbuddy/screens/Gastos/viewmodel/gastos_viewmodel.dart';
import 'package:finbuddy/screens/GraficoDeGastos/viewmodel/graficos_viewmodel.dart';
import 'package:finbuddy/screens/Home/home_screen.dart';
import 'package:finbuddy/screens/Login/login_screen.dart';
import 'package:finbuddy/screens/Home/viewmodel/home_viewmodel.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
// IMPORTAÇÕES DOS MODELOS
import 'package:finbuddy/shared/core/models/ganho_model.dart';
import 'package:finbuddy/shared/core/models/gasto_model.dart';
import 'package:finbuddy/shared/core/models/grafico_model.dart';
import 'package:finbuddy/shared/core/models/cartao_model.dart';
import 'package:finbuddy/shared/core/models/categoria_model.dart';
import 'package:finbuddy/shared/core/models/tipo_pagamento_model.dart';

import '../../mocks/mocks.mocks.dart';

class FakeHomeViewModel extends ChangeNotifier implements HomeViewModel {
  @override
  bool get isLoading => false;
  @override
  Map<String, double> get balanceData => {'saldo': 0.0, 'gastos': 0.0};
  @override
  String? get pendingAction => null;
  @override
  bool get isBalanceVisibleSaldo => false;
  @override
  bool get isBalanceVisibleGasto => false;
  @override
  Future<void> initialize() async {}
  @override
  void clearPendingAction() {}
  @override
  void toggleSaldoVisibility() {}
  @override
  void toggleGastosVisibility() {}
  @override
  void refreshBalance() {}
}

class FakeGanhosViewModel extends ChangeNotifier implements GanhosViewModel {
  // CORREÇÃO: Declaramos o campo que a interface exige. Sem @override ou late.
  @override
  Stream<List<GanhoModel>> ganhosStream = Stream.value(<GanhoModel>[]);

  @override
  Future<void> excluirGanho(String ganhoId) async {}

  @override
  Future<bool> salvarGanho(GanhoModel ganho) async => true;
}

class FakeGastosViewModel extends ChangeNotifier implements GastosViewModel {
  // CORREÇÃO: Declaramos os campos que a interface exige. Sem @override ou late.
  @override
  Stream<List<GastoModel>> gastosStream = Stream.value(<GastoModel>[]);
  @override
  List<CategoriaModel> categorias = [];
  @override
  List<CartaoModel> cartoes = [];
  @override
  List<TipoPagamentoModel> tiposPagamento = [];
  @override
  bool isDialogLoading = false;

  @override
  Future<void> loadDialogDependencies() async {}
  @override
  Future<void> excluirGasto(String gastoId) async {}
  @override
  Future<bool> salvarGasto(GastoModel gasto) async => true;
}


class FakeGraficosViewModel extends ChangeNotifier implements GraficosViewModel {
  @override
  bool get isLoading => false;
  @override
  GraficoModel? get chartData => null;
  @override
  int get anoSelecionado => DateTime.now().year;
  @override
  int get mesSelecionado => DateTime.now().month;
  @override
  TipoGrafico get tipoSelecionado => TipoGrafico.coluna;
  @override
  int? get indiceSelecionado => null;

  @override
  Future<void> loadChartData() async {}
  @override
  void changeMonth(int newMonth) {}
  @override
  void changeChartType(TipoGrafico newType) {}
  @override
  void onPieSectionTouched(int? index) {}
}


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late LoginViewModel loginViewModel;
  late FakeHomeViewModel fakeHomeViewModel;
  late FakeGanhosViewModel fakeGanhosViewModel;
  late FakeGastosViewModel fakeGastosViewModel;
  late FakeGraficosViewModel fakeGraficosViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginViewModel = LoginViewModel(repository: mockAuthRepository);
    fakeHomeViewModel = FakeHomeViewModel();
    fakeGanhosViewModel = FakeGanhosViewModel();
    fakeGastosViewModel = FakeGastosViewModel();
    fakeGraficosViewModel = FakeGraficosViewModel();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginViewModel>.value(value: loginViewModel),
          ChangeNotifierProvider<HomeViewModel>.value(value: fakeHomeViewModel),
          ChangeNotifierProvider<GanhosViewModel>.value(value: fakeGanhosViewModel),
          ChangeNotifierProvider<GastosViewModel>.value(value: fakeGastosViewModel),
          ChangeNotifierProvider<GraficosViewModel>.value(value: fakeGraficosViewModel),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/home': (_) => const HomeScreen(),
          },
        ),
      ),
    );
  }

  group('Testes de Fluxo de Login', () {
    testWidgets('Botão de login deve estar desabilitado e habilitar após preenchimento', (tester) async {
      await pumpLoginScreen(tester);
      ElevatedButton loginButton = tester.widget(find.byKey(const Key('loginButton')));
      expect(loginButton.onPressed, isNull);

      await tester.enterText(find.byKey(const Key('emailField')), 'teste@email.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.pump();

      loginButton = tester.widget(find.byKey(const Key('loginButton')));
      expect(loginButton.onPressed, isNotNull);
    });

    testWidgets('Deve navegar para a HomeScreen em caso de login bem-sucedido', (tester) async {
      // 1. Crie o 'controlador' da promessa
      final completer = Completer<UserCredential>();
      final mockUserCredential = MockUserCredential();

      await pumpLoginScreen(tester);

      // 2. Configure o mock para retornar a promessa (o futuro)
      when(mockAuthRepository.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) => completer.future);

      await tester.enterText(find.byKey(const Key('emailField')), 'teste@email.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.pump();

      // 3. Toque no botão. A execução vai PAUSAR no ViewModel, esperando o completer.
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // Renderiza o frame com o loader

      // 4. AGORA, o estado de loading é garantido. Verifique.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 5. Complete a promessa para destravar a execução do ViewModel.
      completer.complete(mockUserCredential);

      // 6. Aguarde a UI se estabilizar após a conclusão da promessa.
      await tester.pumpAndSettle();

      // 7. Verifique o resultado final.
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Deve exibir mensagem de erro em caso de falha no login', (tester) async {
      // 1. Crie o 'controlador' da promessa
      final completer = Completer<UserCredential>();
      const errorMessage = 'Email ou senha inválidos.';
      final exception = FirebaseAuthException(code: 'invalid-credential', message: errorMessage);

      await pumpLoginScreen(tester);

      // 2. Configure o mock para retornar a promessa
      when(mockAuthRepository.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) => completer.future);

      await tester.enterText(find.byKey(const Key('emailField')), 'errado@email.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'senhaerrada');
      await tester.pump();

      // 3. Toque no botão para pausar a execução no estado de loading
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // 4. Verifique se o loader apareceu
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 5. Complete a promessa com um ERRO para destravar a execução
      completer.completeError(exception);

      // 6. Aguarde a UI se estabilizar
      await tester.pumpAndSettle();

      // 7. Verifique o resultado final
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
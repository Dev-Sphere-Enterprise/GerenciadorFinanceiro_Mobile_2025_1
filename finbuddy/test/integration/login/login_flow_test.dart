import 'package:finbuddy/screens/Home/home_screen.dart';
import 'package:finbuddy/screens/Login/login_screen.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';
import 'package:finbuddy/screens/Home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late LoginViewModel loginViewModel;
  late FakeHomeViewModel fakeHomeViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginViewModel = LoginViewModel(repository: mockAuthRepository);
    fakeHomeViewModel = FakeHomeViewModel();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginViewModel>.value(value: loginViewModel),
          ChangeNotifierProvider<HomeViewModel>.value(value: fakeHomeViewModel),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {'/home': (_) => const HomeScreen()},
        ),
      ),
    );
  }

  group('Testes de Fluxo de Login', () {
    testWidgets(
      'Botão de login deve estar desabilitado inicialmente e habilitar após preenchimento',
      (tester) async {
        await pumpLoginScreen(tester);

        ElevatedButton loginButton = tester.widget(
          find.byKey(const Key('loginButton')),
        );
        expect(loginButton.onPressed, isNull);

        await tester.enterText(
          find.byKey(const Key('emailField')),
          'teste@email.com',
        );
        await tester.enterText(
          find.byKey(const Key('passwordField')),
          '123456',
        );
        await tester.pump();

        loginButton = tester.widget(find.byKey(const Key('loginButton')));
        expect(loginButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'Deve navegar para a HomeScreen em caso de login bem-sucedido',
      (tester) async {
        // ARRANGE
        final mockUserCredential = MockUserCredential();
        when(
          mockAuthRepository.signInWithEmailAndPassword(any, any),
        ).thenAnswer((_) async => mockUserCredential);

        await pumpLoginScreen(tester);

        await tester.enterText(
          find.byKey(const Key('emailField')),
          'teste@email.com',
        );
        await tester.enterText(
          find.byKey(const Key('passwordField')),
          '123456',
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('loginButton')));

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets('Deve exibir mensagem de erro em caso de falha no login', (
      tester,
    ) async {
      const errorMessage = 'Email ou senha inválidos.';
      when(mockAuthRepository.signInWithEmailAndPassword(any, any)).thenThrow(
        FirebaseAuthException(
          code: 'invalid-credential',
          message: errorMessage,
        ),
      );

      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'errado@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'senhaerrada',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('loginButton')));

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}

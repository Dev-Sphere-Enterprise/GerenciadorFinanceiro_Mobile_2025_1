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
  // --- GETTERS ---
  // Fornecemos valores padrão para os getters.
  @override
  bool get isLoading => false; // Começa como 'carregado' para não mostrar um loader infinito.

  @override
  Map<String, double> get balanceData => {'saldo': 0.0, 'gastos': 0.0};

  @override
  String? get pendingAction => null;

  @override
  bool get isBalanceVisibleSaldo => false;

  @override
  bool get isBalanceVisibleGasto => false;

  // --- MÉTODOS ---
  // Métodos podem ter corpos vazios, pois só precisam existir para o teste compilar.
  @override
  Future<void> initialize() async {
    // Não faz nada no fake.
  }

  @override
  void clearPendingAction() {
    // Não faz nada no fake.
  }

  @override
  void toggleSaldoVisibility() {
    // Não faz nada no fake.
  }

  @override
  void toggleGastosVisibility() {
    // Não faz nada no fake.
  }

  @override
  void refreshBalance() {
    // Não faz nada no fake.
  }
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
          routes: {
            '/home': (_) => const HomeScreen(),
          },
        ),
      ),
    );
  }

  group('Testes de Fluxo de Login', () {
    testWidgets('Botão de login deve estar desabilitado inicialmente e habilitar após preenchimento', (tester) async {
      // ARRANGE
      await pumpLoginScreen(tester);

      // ACT & ASSERT

      // 1. Verifica se o botão "ENTRAR" está desabilitado (onPressed == null)
      ElevatedButton loginButton = tester.widget(find.byKey(const Key('loginButton')));
      expect(loginButton.onPressed, isNull);

      // 2. Simula o preenchimento do email e senha
      await tester.enterText(find.byKey(const Key('emailField')), 'teste@email.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');

      // pump() avança um frame para que o listener do controller atualize o estado
      await tester.pump();

      // 3. Verifica se o botão agora está habilitado (onPressed != null)
      loginButton = tester.widget(find.byKey(const Key('loginButton')));
      expect(loginButton.onPressed, isNotNull);
    });

    testWidgets('Deve navegar para a HomeScreen em caso de login bem-sucedido', (tester) async {
      // ARRANGE
      await pumpLoginScreen(tester);
      final mockUserCredential = MockUserCredential();
      when(mockAuthRepository.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => mockUserCredential);

      // ACT
      await tester.enterText(find.byKey(const Key('emailField')), 'teste@email.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.pump();
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Deve exibir mensagem de erro em caso de falha no login', (tester) async {
      // ARRANGE
      await pumpLoginScreen(tester);
      const errorMessage = 'Email ou senha inválidos.';

      // Configura o mock para lançar uma exceção quando o método for chamado
      when(mockAuthRepository.signInWithEmailAndPassword(any, any))
          .thenThrow(FirebaseAuthException(code: 'invalid-credential', message: errorMessage));

      // ACT
      await tester.enterText(find.byKey(const Key('emailField')), 'errado@email.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'senhaerrada');
      await tester.pump();

      await tester.tap(find.byKey(const Key('loginButton')));

      // Espera o CircularProgressIndicator aparecer
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Espera a UI se estabilizar após a falha
      await tester.pumpAndSettle();

      // ASSERT
      // Verifica se a mensagem de erro esperada está na tela
      expect(find.text(errorMessage), findsOneWidget);
      // Garante que a navegação não ocorreu
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
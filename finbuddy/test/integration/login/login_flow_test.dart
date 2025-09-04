import 'package:finbuddy/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:finbuddy/screens/Login/login_screen.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';

// Ele nos dá controle total sobre os resultados do login durante o teste.
class FakeLoginViewModel extends ChangeNotifier implements LoginViewModel {
  bool _isLoading = false;
  String? _errorMessage;
  bool _shouldLoginSucceed = true;

  @override
  final emailController = TextEditingController();
  @override
  final passwordController = TextEditingController();

  // Método para o teste controlar se o login deve falhar ou ter sucesso
  void setLoginOutcome({required bool succeed}) {
    _shouldLoginSucceed = succeed;
  }

  @override
  Future<bool> loginWithEmail() async {
    _isLoading = true;
    notifyListeners();

    // Simula uma pequena espera, como uma chamada de rede
    await Future.delayed(const Duration(milliseconds: 500));

    if (_shouldLoginSucceed && emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Email ou senha inválidos";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Implementações necessárias pela interface, mas não usadas neste teste ---
  @override
  bool get isFormValid => emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  @override
  Future<bool> loginWithGoogle() async => _shouldLoginSucceed;
}


void main() {
  // Inicializa o binding para testes de integração
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeLoginViewModel fakeViewModel;

  // Roda antes de cada teste
  setUp(() {
    fakeViewModel = FakeLoginViewModel();
  });

  // Função auxiliar para "inflar" a LoginScreen com o nosso provider falso
  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      // A LoginScreen precisa de um MaterialApp para funcionar
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: fakeViewModel,
          child: const LoginScreen(),
        ),
        // Adiciona uma rota para a HomeScreen para que a navegação funcione no teste
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }

  group('Fluxo de Login', () {

    testWidgets('Deve logar com sucesso e navegar para a HomeScreen', (WidgetTester tester) async {
      // ARRANGE
      // Configura o nosso ViewModel falso para retornar sucesso no login
      fakeViewModel.setLoginOutcome(succeed: true);
      await pumpLoginScreen(tester);

      // ACT
      // Encontra os campos de texto pelo seu label e insere os dados
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'teste@exemplo.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), '123456');
      
      // Aguarda um frame para o ViewModel atualizar o estado do botão
      await tester.pump(); 

      // Clica no botão de entrar
      await tester.tap(find.text('ENTRAR'));
      
      // Aguarda todas as animações e chamadas assíncronas terminarem (login e navegação)
      await tester.pumpAndSettle();

      // ASSERT
      // Verifica se a tela de Login não está mais visível
      expect(find.byType(LoginScreen), findsNothing);
      // Verifica se a HomeScreen apareceu na árvore de widgets
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Deve mostrar uma mensagem de erro em caso de falha no login', (WidgetTester tester) async {
      // ARRANGE
      // Configura o nosso ViewModel falso para retornar FALHA no login
      fakeViewModel.setLoginOutcome(succeed: false);
      await pumpLoginScreen(tester);

      // ACT
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'email@errado.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'senhaerrada');
      await tester.pump();
      await tester.tap(find.text('ENTRAR'));
      
      // Aguarda as chamadas e a atualização da UI (mostrar o erro)
      await tester.pumpAndSettle();

      // ASSERT
      // Verifica se a mensagem de erro do nosso FakeViewModel apareceu na tela
      expect(find.text("Email ou senha inválidos"), findsOneWidget);
      // Verifica se o app permaneceu na tela de Login
      expect(find.byType(LoginScreen), findsOneWidget);
      // Verifica se a HomeScreen NÃO apareceu
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
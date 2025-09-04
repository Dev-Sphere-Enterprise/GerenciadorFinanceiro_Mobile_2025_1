import 'package:finbuddy/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finbuddy/screens/Login/login_screen.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';

// Classe "Fake" para simular o ViewModel, dando controle total ao teste
class FakeLoginViewModel extends ChangeNotifier implements LoginViewModel {
  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;

  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  bool _isFormValid = false;
  @override
  bool get isFormValid => _isFormValid;

  @override
  final emailController = TextEditingController();
  @override
  final passwordController = TextEditingController();

  bool _loginShouldSucceed = true;
  bool loginWithEmailCalled = false;

  void setLoginOutcome(bool success) {
    _loginShouldSucceed = success;
  }

  @override
  Future<bool> loginWithEmail() async {
    loginWithEmailCalled = true;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100)); // Simula latência

    if (!_loginShouldSucceed) {
      _errorMessage = 'Credenciais inválidas';
    }
    _isLoading = false;
    notifyListeners();
    return _loginShouldSucceed;
  }

  // --- Implementações não necessárias para este teste ---
  @override
  void _validateForm() {}
  @override
  Future<bool> loginWithGoogle() async => true;
}

void main() {
  late FakeLoginViewModel fakeViewModel;

  // Função auxiliar para criar a tela dentro de um ambiente testável
  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // Fornece o ViewModel falso para a LoginScreen
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: fakeViewModel,
          child: const LoginScreen(),
        ),
        // Define uma rota para a HomeScreen para testar a navegação
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }

  setUp(() {
    fakeViewModel = FakeLoginViewModel();
  });

  testWidgets('LoginScreen deve renderizar o estado inicial corretamente', (tester) async {
    // Arrange
    await pumpLoginScreen(tester);

    // Assert
    expect(find.text('FinBuddy'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Senha'), findsOneWidget);

    // Verifica se o botão ENTRAR está desabilitado
    final entrarButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'ENTRAR'));
    expect(entrarButton.onPressed, isNull);
  });

  testWidgets('Botão ENTRAR deve habilitar quando os campos são preenchidos', (tester) async {
    // Arrange
    await pumpLoginScreen(tester);

    // Act
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'a@a.com');
    await tester.enterText(find.widgetWithText(TextField, 'Senha'), '123');

    // Simula a validação do formulário no ViewModel falso
    fakeViewModel._isFormValid = true;
    fakeViewModel.notifyListeners();
    await tester.pump(); // Redesenha a tela

    // Assert
    final entrarButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'ENTRAR'));
    expect(entrarButton.onPressed, isNotNull);
  });

  testWidgets('Deve mostrar CircularProgressIndicator durante o login', (tester) async {
    // Arrange
    await pumpLoginScreen(tester);
    fakeViewModel.setLoginOutcome(true);
    fakeViewModel.emailController.text = 'a@a.com';
    fakeViewModel.passwordController.text = '123';
    fakeViewModel._isFormValid = true;
    fakeViewModel.notifyListeners();
    await tester.pump();

    // Act
    await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));
    await tester.pump(); // Inicia o estado de loading

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Deve mostrar mensagem de erro em caso de falha no login', (tester) async {
    // Arrange
    await pumpLoginScreen(tester);
    fakeViewModel.setLoginOutcome(false); // Configura o login para falhar
    fakeViewModel.emailController.text = 'a@a.com';
    fakeViewModel.passwordController.text = '123';
    fakeViewModel._isFormValid = true;
    fakeViewModel.notifyListeners();
    await tester.pump();

    // Act
    await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));
    await tester.pumpAndSettle(); // Espera o processo de login terminar

    // Assert
    expect(find.text('Credenciais inválidas'), findsOneWidget);
  });
}
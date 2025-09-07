// test/widgets/login/login_screen_test.dart

import 'package:finbuddy/screens/Login/login_screen.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../mocks/login_flow_test.mocks.dart'; // Ajuste se o nome do mock for diferente

// Widget "dublê" para a HomeScreen, garantindo isolamento total.
class FakeHomeScreen extends StatelessWidget {
  const FakeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Navegou com Sucesso', key: Key('fakeHomeScreen')),
      ),
    );
  }
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginViewModel loginViewModel;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginViewModel = LoginViewModel(repository: mockAuthRepository);
    mockUserCredential = MockUserCredential();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginViewModel>.value(value: loginViewModel),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {'/home': (context) => const FakeHomeScreen()},
        ),
      ),
    );
  }

  group('Testes de Widget da LoginScreen', () {
    testWidgets(
      'Deve navegar para a FakeHomeScreen em caso de login bem-sucedido',
      (tester) async {
        // ARRANGE
        when(
          mockAuthRepository.signInWithEmailAndPassword(any, any),
        ).thenAnswer((_) async => mockUserCredential);

        await pumpLoginScreen(tester);

        // ACT
        await tester.enterText(
          find.byKey(const Key('emailField')),
          'teste@email.com',
        );
        await tester.enterText(
          find.byKey(const Key('passwordField')),
          '123456',
        );
        await tester.pump(); // Garante que o botão seja habilitado

        await tester.tap(find.byKey(const Key('loginButton')));

        // ✨ AJUSTE PRINCIPAL ✨
        // Espera todas as animações e futuros terminarem, incluindo o loading e a navegação.
        await tester.pumpAndSettle();

        // ASSERT
        // Foca apenas no resultado final: a navegação ocorreu.
        expect(find.byKey(const Key('fakeHomeScreen')), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets('Deve exibir mensagem de erro em caso de falha no login', (
      tester,
    ) async {
      // ARRANGE
      when(
        mockAuthRepository.signInWithEmailAndPassword(any, any),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await pumpLoginScreen(tester);

      // ACT
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'errado@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'senhaerrada',
      );
      await tester.pump(); // Garante que o botão seja habilitado

      await tester.tap(find.byKey(const Key('loginButton')));

      // ✨ MESMO AJUSTE APLICADO AQUI ✨
      await tester.pumpAndSettle();

      // ASSERT
      // Foca apenas no resultado final: a mensagem de erro está visível.
      expect(find.text('Email ou senha inválidos.'), findsOneWidget);
      expect(find.byType(FakeHomeScreen), findsNothing);
    });
  });
}

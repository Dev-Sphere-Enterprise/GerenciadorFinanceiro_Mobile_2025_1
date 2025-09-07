import 'package:finbuddy/screens/Login/login_screen.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../mocks/login_flow_test.mocks.dart';

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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  group('Testes de Fluxo de Login', () {
    testWidgets(
      'Deve navegar para a FakeHomeScreen em caso de login bem-sucedido',
      (tester) async {
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

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('fakeHomeScreen')), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });
}

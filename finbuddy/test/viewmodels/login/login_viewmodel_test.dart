import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:finbuddy/shared/core/repositories/auth_repository.dart';
import 'package:finbuddy/screens/Login/viewmodel/login_viewmodel.dart';
import 'login_viewmodel_test.mocks.dart';

// 👇 inclua UserCredential aqui também
@GenerateMocks([AuthRepository, UserCredential])
void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginViewModel viewModel;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserCredential = MockUserCredential();
    viewModel = LoginViewModel(repository: mockAuthRepository);
  });

  group('LoginViewModel', () {
    test('isFormValid deve ser falso inicialmente', () {
      expect(viewModel.isFormValid, isFalse);
    });

    test('isFormValid deve se tornar verdadeiro quando ambos os campos são preenchidos', () {
      // Act
      viewModel.emailController.text = 'teste@teste.com';
      viewModel.passwordController.text = '123456';

      // Assert
      expect(viewModel.isFormValid, isTrue);
    });

    group('loginWithEmail', () {
      test('deve retornar true em caso de sucesso', () async {
        // Arrange
        viewModel.emailController.text = 'teste@teste.com';
        viewModel.passwordController.text = '123456';

        when(mockAuthRepository.signInWithEmailAndPassword(any, any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await viewModel.loginWithEmail();

        // Assert
        expect(result, isTrue);
        expect(viewModel.errorMessage, isNull);
        verify(mockAuthRepository.signInWithEmailAndPassword('teste@teste.com', '123456')).called(1);
      });

      test('deve retornar false e definir errorMessage em caso de falha', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário não encontrado',
        );

        viewModel.emailController.text = 'errado@teste.com';
        viewModel.passwordController.text = '123456';

        when(mockAuthRepository.signInWithEmailAndPassword(any, any))
            .thenThrow(exception);

        // Act
        final result = await viewModel.loginWithEmail();

        // Assert
        expect(result, isFalse);
        expect(viewModel.errorMessage, 'Usuário não encontrado');
      });
    });
  });
}

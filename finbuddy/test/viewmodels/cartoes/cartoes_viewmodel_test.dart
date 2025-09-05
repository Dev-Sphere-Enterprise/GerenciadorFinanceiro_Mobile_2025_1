// test/viewmodels/cartoes_viewmodel_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:finbuddy/shared/core/models/cartao_model.dart';
import 'package:finbuddy/shared/core/repositories/cartoes_repository.dart';
import 'package:finbuddy/screens/Cartoes/viewmodel/cartoes_viewmodel.dart';
import 'cartoes_viewmodel_test.mocks.dart';

@GenerateMocks([CartoesRepository])
void main() {
  late MockCartoesRepository mockRepository;
  late CartoesViewModel viewModel;

  setUp(() {
    mockRepository = MockCartoesRepository();
    when(mockRepository.getCartoesStream()).thenAnswer((_) => Stream.value([]));
    viewModel = CartoesViewModel(repository: mockRepository);
  });

  group('CartoesViewModel', () {
    final tCartao = CartaoModel(
      id: '123',
      idUsuario: 'user1',
      nome: 'Cartão Teste',
      valorFaturaAtual: 500.0,
      limiteCredito: 1500.0,
      dataFechamento: DateTime.now(),
      dataVencimento: DateTime.now().add(const Duration(days: 10)),
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );

    test('construtor deve chamar getCartoesStream no repositório', () {
      // Arrange (feito no setUp)
      // Act (a criação do viewModel no setUp)
      // Assert
      // Verifica se o método foi chamado exatamente uma vez
      verify(mockRepository.getCartoesStream()).called(1);
    });

    group('salvarCartao', () {
      test('deve retornar true quando o salvamento no repositório for bem-sucedido', () async {
        // Arrange
        when(mockRepository.addOrEditCartao(any)).thenAnswer((_) async {});

        // Act
        final result = await viewModel.salvarCartao(tCartao);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addOrEditCartao(tCartao)).called(1);
      });

      test('deve retornar false quando o repositório lançar uma exceção', () async {
        // Arrange
        when(mockRepository.addOrEditCartao(any)).thenThrow(Exception('Falha ao salvar'));

        // Act
        final result = await viewModel.salvarCartao(tCartao);

        // Assert
        expect(result, isFalse);
      });
    });

    group('excluirCartao', () {
      const tCartaoId = 'cartao-123';
      test('deve chamar deleteCartao no repositório com o ID correto', () async {
        // Arrange
        when(mockRepository.deleteCartao(any)).thenAnswer((_) async {});

        // Act
        await viewModel.excluirCartao(tCartaoId);

        // Assert
        verify(mockRepository.deleteCartao(tCartaoId)).called(1);
      });

      test('não deve lançar uma exceção se o repositório falhar', () {
        // Arrange
        when(mockRepository.deleteCartao(any)).thenThrow(Exception('Falha ao deletar'));

        // Act & Assert
        // Apenas esperamos que a função execute normalmente, sem quebrar o app
        expect(() async => await viewModel.excluirCartao(tCartaoId), returnsNormally);
      });
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:finbuddy/shared/core/models/ganho_model.dart';
import 'package:finbuddy/shared/core/repositories/ganhos_repository.dart';
import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';

import 'ganhos_viewmodel_test.mocks.dart'; // Arquivo a ser gerado

@GenerateMocks([GanhosRepository])
void main() {
  late MockGanhosRepository mockRepository;
  late GanhosViewModel viewModel;

  setUp(() {
    mockRepository = MockGanhosRepository();
    viewModel = GanhosViewModel(repository: mockRepository);
  });

  group('GanhosViewModel', () {
    final tGanho = GanhoModel(
      id: 'g1',
      nome: 'Salário',
      valor: 5000.0,
      dataRecebimento: DateTime.now(),
      recorrencia: false, // O ViewModel deve mudar isso para true
    );

    test('construtor deve chamar getGanhosFixosStream no repositório', () {
      verify(mockRepository.getGanhosFixosStream()).called(1);
    });

    group('salvarGanho', () {
      test('deve chamar addOrEditGanho com recorrencia=true e retornar true em caso de sucesso', () async {
        // Arrange
        when(mockRepository.addOrEditGanho(any)).thenAnswer((_) async {});

        // Act
        final result = await viewModel.salvarGanho(tGanho);

        // Assert
        expect(result, isTrue);

        // Captura o argumento para verificar se `recorrencia` foi setado para true
        final captured = verify(mockRepository.addOrEditGanho(captureAny)).captured;
        expect(captured.first.recorrencia, isTrue);
      });

      test('deve retornar false se o repositório lançar uma exceção', () async {
        // Arrange
        when(mockRepository.addOrEditGanho(any)).thenThrow(Exception('Erro de DB'));

        // Act
        final result = await viewModel.salvarGanho(tGanho);

        // Assert
        expect(result, isFalse);
      });
    });

    group('excluirGanho', () {
      test('deve chamar deleteGanho no repositório', () async {
        // Arrange
        when(mockRepository.deleteGanho(any)).thenAnswer((_) async {});

        // Act
        await viewModel.excluirGanho('g1');

        // Assert
        verify(mockRepository.deleteGanho('g1')).called(1);
      });
    });
  });
}
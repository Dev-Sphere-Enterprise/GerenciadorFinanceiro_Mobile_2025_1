import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:finbuddy/shared/core/models/aporte_meta_model.dart';
import 'package:finbuddy/shared/core/repositories/aportes_repository.dart';
import 'package:finbuddy/screens/Aportes/viewmodel/aportes_viewmodel.dart';
import 'aportes_viewmodel_test.mocks.dart';

@GenerateMocks([AportesRepository])
void main() {
  late MockAportesRepository mockRepository;
  late AportesViewModel viewModel;
  const tMetaId = 'meta-123';

  setUp(() {
    mockRepository = MockAportesRepository();
    viewModel = AportesViewModel(metaId: tMetaId, repository: mockRepository);
  });

  group('AportesViewModel Tests', () {

    test('Construtor deve chamar getAportesStream', () {
      verify(mockRepository.getAportesStream(tMetaId)).called(1);
    });

    // Testes para o método salvarAporte
    group('salvarAporte', () {
      final tAporte = AporteMetaModel(
        idMeta: tMetaId,
        valor: 100.0,
        dataAporte: DateTime.now(),
        deletado: false,
      );

      test('deve retornar true ao salvar um NOVO aporte com sucesso', () async {
        // Arrange: Configura o comportamento esperado do mock
        when(mockRepository.addOrEditAporte(any, any)).thenAnswer((_) async => Future.value());

        // Act: Executa a função a ser testada
        final result = await viewModel.salvarAporte(valor: 100.0, data: DateTime.now());

        // Assert: Verifica o resultado
        expect(result, isTrue);
        // Verifica se o método do repositório foi chamado
        verify(mockRepository.addOrEditAporte(tMetaId, any)).called(1);
      });

      test('deve retornar false se o repositório lançar uma exceção', () async {
        // Arrange: Configura o mock para lançar um erro
        when(mockRepository.addOrEditAporte(any, any)).thenThrow(Exception('Falha no DB'));

        // Act: Executa a função
        final result = await viewModel.salvarAporte(valor: 100.0, data: DateTime.now());

        // Assert: Verifica se o resultado é falso
        expect(result, isFalse);
      });
    });

    // Testes para o método excluirAporte
    group('excluirAporte', () {
      const tAporteId = 'aporte-abc';
      test('deve chamar deleteAporte no repositório com os IDs corretos', () async {
        // Arrange
        when(mockRepository.deleteAporte(any, any)).thenAnswer((_) async => Future.value());

        // Act
        await viewModel.excluirAporte(tAporteId);

        // Assert
        verify(mockRepository.deleteAporte(tMetaId, tAporteId)).called(1);
      });

      test('não deve lançar exceção se o repositório falhar', () async {
        // Arrange
        when(mockRepository.deleteAporte(any, any)).thenThrow(Exception('Falha ao deletar'));

        // Act & Assert
        // O `expect` garante que nenhuma exceção vaze do método, pois o catch a captura
        expect(() async => await viewModel.excluirAporte(tAporteId), returnsNormally);
      });
    });
    
    // Testes para o método recalcularMeta
    group('recalcularMeta', () {
      test('deve chamar recalcularEAtualizarValorMeta no repositório', () async {
        when(mockRepository.recalcularEAtualizarValorMeta(any)).thenAnswer((_) async => Future.value());

        // Act
        await viewModel.recalcularMeta();

        // Assert
        verify(mockRepository.recalcularEAtualizarValorMeta(tMetaId)).called(1);
      });
    });
  });
}
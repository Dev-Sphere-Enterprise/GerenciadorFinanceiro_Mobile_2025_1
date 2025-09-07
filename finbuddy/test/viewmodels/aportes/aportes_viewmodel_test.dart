import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
    when(
      mockRepository.getAportesStream(tMetaId),
    ).thenAnswer((_) => Stream.value([]));
    viewModel = AportesViewModel(metaId: tMetaId, repository: mockRepository);
  });

  group('AportesViewModel Tests', () {
    test('Construtor deve chamar getAportesStream', () {
      verify(mockRepository.getAportesStream(tMetaId)).called(1);
    });

    group('salvarAporte', () {

      test('deve retornar true ao salvar um NOVO aporte com sucesso', () async {
        when(
          mockRepository.addOrEditAporte(any, any),
        ).thenAnswer((_) async => Future.value());

        final result = await viewModel.salvarAporte(
          valor: 100.0,
          data: DateTime.now(),
        );

        expect(result, isTrue);
        verify(mockRepository.addOrEditAporte(tMetaId, any)).called(1);
      });

      test('deve retornar false se o repositório lançar uma exceção', () async {
        when(
          mockRepository.addOrEditAporte(any, any),
        ).thenThrow(Exception('Falha no DB'));

        final result = await viewModel.salvarAporte(
          valor: 100.0,
          data: DateTime.now(),
        );

        expect(result, isFalse);
      });
    });

    group('excluirAporte', () {
      const tAporteId = 'aporte-abc';
      test(
        'deve chamar deleteAporte no repositório com os IDs corretos',
        () async {
          when(
            mockRepository.deleteAporte(any, any),
          ).thenAnswer((_) async => Future.value());

          await viewModel.excluirAporte(tAporteId);

          verify(mockRepository.deleteAporte(tMetaId, tAporteId)).called(1);
        },
      );

      test('não deve lançar exceção se o repositório falhar', () async {
        when(
          mockRepository.deleteAporte(any, any),
        ).thenThrow(Exception('Falha ao deletar'));

        expect(
          () async => await viewModel.excluirAporte(tAporteId),
          returnsNormally,
        );
      });
    });

    group('recalcularMeta', () {
      test(
        'deve chamar recalcularEAtualizarValorMeta no repositório',
        () async {
          when(
            mockRepository.recalcularEAtualizarValorMeta(any),
          ).thenAnswer((_) async => Future.value());

          await viewModel.recalcularMeta();

          verify(
            mockRepository.recalcularEAtualizarValorMeta(tMetaId),
          ).called(1);
        },
      );
    });
  });
}

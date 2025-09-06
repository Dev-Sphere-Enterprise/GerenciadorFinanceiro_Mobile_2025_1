import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:finbuddy/shared/core/models/ganho_model.dart';
import 'package:finbuddy/shared/core/repositories/ganhos_repository.dart';
import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'ganhos_viewmodel_test.mocks.dart';

@GenerateMocks([GanhosRepository])
void main() {
  late MockGanhosRepository mockRepository;
  late GanhosViewModel viewModel;

  setUp(() {
    mockRepository = MockGanhosRepository();
    when(
      mockRepository.getGanhosFixosStream(),
    ).thenAnswer((_) => Stream.value([]));
    viewModel = GanhosViewModel(repository: mockRepository);
  });

  group('GanhosViewModel', () {
    final tGanho = GanhoModel(
      id: 'g1',
      idUsuario: '123456',
      nome: 'Salário',
      valor: 5000.0,
      dataRecebimento: DateTime.now(),
      recorrencia: false,
      deletado: false,
      dataAtualizacao: DateTime.now(),
      dataCriacao: DateTime.now(),
    );

    test('construtor deve chamar getGanhosFixosStream no repositório', () {
      verify(mockRepository.getGanhosFixosStream()).called(1);
    });

    group('salvarGanho', () {
      test(
        'deve chamar addOrEditGanho com recorrencia=true e retornar true em caso de sucesso',
        () async {
          when(mockRepository.addOrEditGanho(any)).thenAnswer((_) async {});

          final result = await viewModel.salvarGanho(tGanho);

          expect(result, isTrue);

          final captured = verify(
            mockRepository.addOrEditGanho(captureAny),
          ).captured;
          expect(captured.first.recorrencia, isTrue);
        },
      );

      test('deve retornar false se o repositório lançar uma exceção', () async {
        when(
          mockRepository.addOrEditGanho(any),
        ).thenThrow(Exception('Erro de DB'));

        final result = await viewModel.salvarGanho(tGanho);

        expect(result, isFalse);
      });
    });

    group('excluirGanho', () {
      test('deve chamar deleteGanho no repositório', () async {
        when(mockRepository.deleteGanho(any)).thenAnswer((_) async {});

        await viewModel.excluirGanho('g1');

        verify(mockRepository.deleteGanho('g1')).called(1);
      });
    });
  });
}

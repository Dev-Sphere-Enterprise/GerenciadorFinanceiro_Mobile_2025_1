import 'dart:async';
import 'package:finbuddy/screens/Ganhos/ganhos_fixos_screen.dart';
import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'package:finbuddy/shared/core/models/ganho_model.dart';
import 'package:finbuddy/shared/core/repositories/ganhos_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../../mocks/ganhos_flow_test.mocks.dart';

@GenerateMocks([GanhosRepository])
void main() {
  late MockGanhosRepository mockGanhosRepository;
  late GanhosViewModel ganhosViewModel;
  late StreamController<List<GanhoModel>> ganhosController;

  setUp(() {
    mockGanhosRepository = MockGanhosRepository();
    ganhosController = StreamController<List<GanhoModel>>.broadcast();

    when(
      mockGanhosRepository.getGanhosFixosStream(),
    ).thenAnswer((_) => ganhosController.stream);

    ganhosViewModel = GanhosViewModel(repository: mockGanhosRepository);
  });

  tearDown(() {
    ganhosController.close();
  });

  Future<void> pumpGanhosScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<GanhosViewModel>.value(
        value: ganhosViewModel,
        child: const MaterialApp(home: GanhosFixosScreen()),
      ),
    );
  }

  final mockGanho = GanhoModel(
    id: '1',
    nome: 'Salário',
    valor: 5000.0,
    dataRecebimento: DateTime(2025, 9, 5),
    idUsuario: 'uid123',
    dataCriacao: DateTime.now(),
    dataAtualizacao: DateTime.now(),
  );

  group('Testes de Integração da GanhosFixosScreen', () {
    testWidgets('deve exibir a lista de ganhos corretamente', (tester) async {
      await pumpGanhosScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      ganhosController.add([]);
      await tester.pump();
      expect(find.text('Nenhum ganho cadastrado.'), findsOneWidget);

      ganhosController.add([mockGanho]);
      await tester.pump();
      expect(find.text('Salário'), findsOneWidget);
      expect(find.textContaining('5.000,00'), findsOneWidget);
      expect(find.text('Recebimento: Dia 05 de cada mês'), findsOneWidget);
    });

    testWidgets('deve adicionar um novo ganho com sucesso', (tester) async {
      when(mockGanhosRepository.addOrEditGanho(any)).thenAnswer((_) async {});

      await pumpGanhosScreen(tester);
      ganhosController.add([]);
      await tester.pump();

      await tester.tap(find.text('Adicionar Ganho'));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar Ganho Fixo'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('nomeField')), 'Consultoria');
      await tester.enterText(find.byKey(const Key('valorField')), '1500,00');

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      verify(mockGanhosRepository.addOrEditGanho(any)).called(1);
      expect(find.text('Adicionar Ganho Fixo'), findsNothing);
    });

    testWidgets('deve editar um ganho existente com sucesso', (tester) async {
      when(mockGanhosRepository.addOrEditGanho(any)).thenAnswer((_) async {});

      await pumpGanhosScreen(tester);
      ganhosController.add([mockGanho]);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Editar Ganho Fixo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Salário'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('valorField')), '5500,00');

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      verify(mockGanhosRepository.addOrEditGanho(any)).called(1);
    });

    testWidgets('deve excluir um ganho após confirmação', (tester) async {
      when(mockGanhosRepository.deleteGanho(any)).thenAnswer((_) async {});

      await pumpGanhosScreen(tester);
      ganhosController.add([mockGanho]);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar exclusão'), findsOneWidget);

      await tester.tap(find.text('Deletar'));
      await tester.pumpAndSettle();

      verify(mockGanhosRepository.deleteGanho('1')).called(1);
    });
  });
}

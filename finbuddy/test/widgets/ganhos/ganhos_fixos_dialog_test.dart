import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finbuddy/screens/Ganhos/dialog/ganhos_fixos_dialog.dart';
import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'package:finbuddy/shared/core/models/ganho_model.dart';

// Pode reutilizar o FakeViewModel do teste de tela ou criar um novo
class FakeGanhosViewModel extends ChangeNotifier implements GanhosViewModel {
  bool salvarGanhoCalled = false;
  GanhoModel? capturedGanho;

  @override
  Future<bool> salvarGanho(GanhoModel ganho) async {
    salvarGanhoCalled = true;
    capturedGanho = ganho;
    return true;
  }

  @override
  late Stream<List<GanhoModel>> ganhosStream = Stream.value([]);
  @override
  Future<void> excluirGanho(String ganhoId) async {}
  @override
  late final _repository;
}

void main() {
  late FakeGanhosViewModel fakeViewModel;

  Widget createTestableWidget({GanhoModel? ganho}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            // O Provider precisa estar acima do context que chama o dialog
            return ChangeNotifierProvider<GanhosViewModel>.value(
              value: fakeViewModel,
              child: ElevatedButton(
                onPressed: () => showAddOrEditGanhoDialog(context: context, ganho: ganho),
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );
  }

  setUp(() {
    fakeViewModel = FakeGanhosViewModel();
  });

  testWidgets('Dialog de Adicionar Ganho deve chamar salvarGanho e fechar', (tester) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget());

    // Act
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Assert: Verifica se o dialog abriu
    expect(find.text('Adicionar Ganho Fixo'), findsOneWidget);

    // Act
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome:'), 'Salário');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor (R\$):'), '5500,00');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Assert
    expect(fakeViewModel.salvarGanhoCalled, isTrue);
    expect(fakeViewModel.capturedGanho?.nome, 'Salário');
    expect(fakeViewModel.capturedGanho?.valor, 5500.0);
    expect(find.text('Adicionar Ganho Fixo'), findsNothing); // Dialog fechou
  });
}
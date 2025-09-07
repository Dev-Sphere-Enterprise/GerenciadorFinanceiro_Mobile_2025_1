import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finbuddy/screens/Ganhos/dialog/ganhos_fixos_dialog.dart';
import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'package:finbuddy/shared/core/models/ganho_model.dart';

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
}

void main() {
  late FakeGanhosViewModel fakeViewModel;

  Widget createTestableWidget({GanhoModel? ganho}) {
    return ChangeNotifierProvider<GanhosViewModel>.value(
      value: fakeViewModel,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () =>
                    showAddOrEditGanhoDialog(context: context, ganho: ganho),
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      ),
    );
  }

  setUp(() {
    fakeViewModel = FakeGanhosViewModel();
  });

  testWidgets('Dialog de Adicionar Ganho deve chamar salvarGanho e fechar', (
    tester,
  ) async {
    await tester.pumpWidget(createTestableWidget());

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Ganho Fixo'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nomeField')), 'Salário');
    await tester.enterText(find.byKey(const Key('valorField')), '5500.00');

    await tester.pump();

    final salvarButtonFinder = find.ancestor(
      of: find.text('Salvar'),
      matching: find.byType(ElevatedButton),
    );

    final salvarButton = tester.widget<ElevatedButton>(salvarButtonFinder);
    expect(salvarButton.onPressed, isNotNull);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(fakeViewModel.salvarGanhoCalled, isTrue);
    expect(fakeViewModel.capturedGanho?.nome, 'Salário');
    expect(fakeViewModel.capturedGanho?.valor, 5500.0);
    expect(find.text('Adicionar Ganho Fixo'), findsNothing);
  });
}

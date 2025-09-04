// integration_test/ganhos_fixos_flow_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:finbuddy/screens/Ganhos/ganhos_fixos_screen.dart';
import 'package:finbuddy/screens/Ganhos/viewmodel/ganhos_viewmodel.dart';
import 'package:finbuddy/shared/core/models/ganho_model.dart';

class FakeGanhosViewModel extends ChangeNotifier implements GanhosViewModel {
  final List<GanhoModel> _ganhos = [];
  final StreamController<List<GanhoModel>> _streamController = StreamController.broadcast();
  int _idCounter = 0;

  FakeGanhosViewModel() {
    ganhosStream = _streamController.stream;
    _emitCurrentState();
  }

  void _emitCurrentState() => _streamController.add(List.from(_ganhos));

  @override
  late Stream<List<GanhoModel>> ganhosStream;
  @override
  Future<bool> salvarGanho(GanhoModel ganho) async {
    _idCounter++;
    _ganhos.add(ganho.copyWith(id: 'fake_id_$_idCounter', recorrencia: true));
    _emitCurrentState();
    notifyListeners();
    return true;
  }
  @override
  Future<void> excluirGanho(String ganhoId) async {
    _ganhos.removeWhere((g) => g.id == ganhoId);
    _emitCurrentState();
    notifyListeners();
  }
  @override
  late final _repository;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo de Ganhos Fixos: Adicionar e depois deletar um ganho', (tester) async {
    // ARRANGE
    final fakeViewModel = FakeGanhosViewModel();
    await tester.pumpWidget(
      ChangeNotifierProvider<GanhosViewModel>.value(
        value: fakeViewModel,
        child: const MaterialApp(home: GanhosFixosScreen()),
      ),
    );

    // ETAPA 1: ADICIONAR
    await tester.pump();
    expect(find.text('Nenhum ganho cadastrado.'), findsOneWidget);

    await tester.tap(find.text('Adicionar Ganho'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome:'), 'Salário Mensal');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor (R\$):'), '7000,00');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Salário Mensal'), findsOneWidget);
    expect(find.text('Valor: R\$ 7.000,00'), findsOneWidget);

    // ETAPA 2: DELETAR
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar exclusão'), findsOneWidget);
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();

    expect(find.text('Salário Mensal'), findsNothing);
    expect(find.text('Nenhum ganho cadastrado.'), findsOneWidget);
  });
}
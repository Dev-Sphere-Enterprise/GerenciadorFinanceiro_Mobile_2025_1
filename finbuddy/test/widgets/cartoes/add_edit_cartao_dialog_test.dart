// test/widgets/cartoes/add_edit_cartao_dialog_test.dart

import 'package:finbuddy/screens/Cartoes/viewmodel/cartoes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finbuddy/screens/Cartoes/dialog/add_edit_cartao_dialog.dart';
import 'package:finbuddy/shared/core/models/cartao_model.dart';

class FakeCartoesViewModel extends ChangeNotifier implements CartoesViewModel {
  bool salvarCartaoCalled = false;
  CartaoModel? capturedCartao;
  bool _shouldSucceed = true;

  void setSaveOutcome(bool succeed) {
    _shouldSucceed = succeed;
  }

  @override
  Future<bool> salvarCartao(CartaoModel cartao) async {
    salvarCartaoCalled = true;
    capturedCartao = cartao;
    return _shouldSucceed;
  }

  @override
  late Stream<List<CartaoModel>> cartoesStream = Stream.value([]);
  @override
  Future<void> excluirCartao(String cartaoId) async {}
  @override
  late final _repository;
}

void main() {
  late FakeCartoesViewModel fakeViewModel;

  Widget createTestableWidget(Widget child) {
    return ChangeNotifierProvider<CartoesViewModel>.value(
      value: fakeViewModel,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  setUp(() {
    fakeViewModel = FakeCartoesViewModel();
  });

  group('showAddEditCartaoDialog', () {
    testWidgets('Modo Adicionar: deve abrir, preencher e salvar com sucesso', (tester) async {
      // ARRANGE
      fakeViewModel.setSaveOutcome(true);
      await tester.pumpWidget(createTestableWidget(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAddEditCartaoDialog(context: context),
            child: const Text('Abrir'),
          );
        }),
      ));

      // ACT
      // Abre o dialog
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // ASSERT: Verifica se o dialog abriu no modo correto
      expect(find.text('Adicionar Cartão'), findsOneWidget);
      expect(find.byKey(const Key('nomeField')), findsOneWidget);

      // ACT: Preenche o formulário
      await tester.enterText(find.byKey(const Key('nomeField')), 'Novo Cartão');
      await tester.enterText(find.byKey(const Key('limiteField')), '3000.00');
      await tester.enterText(find.byKey(const Key('faturaField')), '150.55');

      // Clica no botão Salvar
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // ASSERT: Verifica se o ViewModel foi chamado e se o dialog fechou
      expect(fakeViewModel.salvarCartaoCalled, isTrue);
      expect(fakeViewModel.capturedCartao?.nome, 'Novo Cartão');
      expect(fakeViewModel.capturedCartao?.limiteCredito, 3000.0);
      expect(fakeViewModel.capturedCartao?.valorFaturaAtual, 150.55);
      expect(fakeViewModel.capturedCartao?.id, isNull);
      expect(find.text('Adicionar Cartão'), findsNothing);
    });

    testWidgets('Botão Salvar deve estar desabilitado se os campos obrigatórios estiverem vazios', (tester) async {
      // ARRANGE
      await tester.pumpWidget(createTestableWidget(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAddEditCartaoDialog(context: context),
            child: const Text('Abrir'),
          );
        }),
      ));

      // ACT
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // ASSERT
      final salvarButton = tester.widget<ElevatedButton>(find.byKey(const Key('salvarButton')));
      expect(salvarButton.onPressed, isNull);

      // ACT: Preenche apenas um campo
      await tester.enterText(find.byKey(const Key('nomeField')), 'Cartão');
      await tester.pump();

      // ASSERT: Botão ainda deve estar desabilitado
      final salvarButton2 = tester.widget<ElevatedButton>(find.byKey(const Key('salvarButton')));
      expect(salvarButton2.onPressed, isNull);

      // ACT: Preenche o segundo campo obrigatório
      await tester.enterText(find.byKey(const Key('limiteField')), '1000.00');
      await tester.pumpAndSettle();

      // ASSERT: Botão agora deve estar habilitado
      final salvarButton3 = tester.widget<ElevatedButton>(find.byKey(const Key('salvarButton')));
      expect(salvarButton3.onPressed, isNotNull);
    });
  });
}
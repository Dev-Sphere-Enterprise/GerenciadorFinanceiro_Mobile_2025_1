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
}

void main() {
  late FakeCartoesViewModel fakeViewModel;

  Widget createTestableWidget(Widget child) {
    return ChangeNotifierProvider<CartoesViewModel>.value(
      value: fakeViewModel,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  setUp(() {
    fakeViewModel = FakeCartoesViewModel();
  });

  group('showAddEditCartaoDialog', () {
    testWidgets('Modo Adicionar: deve abrir, preencher e salvar com sucesso', (
      tester,
    ) async {
      fakeViewModel.setSaveOutcome(true);
      await tester.pumpWidget(
        createTestableWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAddEditCartaoDialog(context: context),
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar Cartão'), findsOneWidget);
      expect(find.byKey(const Key('nomeField')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('nomeField')), 'Novo Cartão');
      await tester.enterText(find.byKey(const Key('limiteField')), '3000.00');
      await tester.enterText(find.byKey(const Key('faturaField')), '150.55');

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(fakeViewModel.salvarCartaoCalled, isTrue);
      expect(fakeViewModel.capturedCartao?.nome, 'Novo Cartão');
      expect(fakeViewModel.capturedCartao?.limiteCredito, 3000.0);
      expect(fakeViewModel.capturedCartao?.valorFaturaAtual, 150.55);
      expect(fakeViewModel.capturedCartao?.id, isNull);
      expect(find.text('Adicionar Cartão'), findsNothing);
    });

    testWidgets(
      'Botão Salvar deve estar desabilitado se os campos obrigatórios estiverem vazios',
      (tester) async {
        await tester.pumpWidget(
          createTestableWidget(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showAddEditCartaoDialog(context: context),
                  child: const Text('Abrir'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        final salvarButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('salvarButton')),
        );
        expect(salvarButton.onPressed, isNull);

        await tester.enterText(find.byKey(const Key('nomeField')), 'Cartão');
        await tester.pump();

        final salvarButton2 = tester.widget<ElevatedButton>(
          find.byKey(const Key('salvarButton')),
        );
        expect(salvarButton2.onPressed, isNull);

        await tester.enterText(find.byKey(const Key('limiteField')), '1000.00');
        await tester.pumpAndSettle();

        final salvarButton3 = tester.widget<ElevatedButton>(
          find.byKey(const Key('salvarButton')),
        );
        expect(salvarButton3.onPressed, isNotNull);
      },
    );
  });
}

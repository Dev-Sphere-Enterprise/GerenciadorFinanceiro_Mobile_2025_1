// test/dialogs/add_edit_cartao_dialog_test.dart

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
      expect(find.widgetWithText(TextFormField, 'Nome:'), findsOneWidget);

      // ACT: Preenche o formulário
      // Usamos `find.byWidgetPredicate` para encontrar os TextFormFields de forma mais precisa
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome:'), 'Novo Cartão');
      await tester.enterText(find.widgetWithText(TextFormField, 'Limite (R\$):'), '3000,00');
      await tester.enterText(find.widgetWithText(TextFormField, 'Fatura (R\$):'), '150,55');
      
      // Clica no botão Salvar
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // ASSERT: Verifica se o ViewModel foi chamado e se o dialog fechou
      expect(fakeViewModel.salvarCartaoCalled, isTrue);
      expect(fakeViewModel.capturedCartao?.nome, 'Novo Cartão');
      expect(fakeViewModel.capturedCartao?.limiteCredito, 3000.0);
      expect(fakeViewModel.capturedCartao?.valorFaturaAtual, 150.55);
      expect(fakeViewModel.capturedCartao?.id, isNull);
      expect(find.text('Adicionar Cartão'), findsNothing); // Verifica se o dialog fechou
    });

    testWidgets('Modo Editar: deve abrir com dados preenchidos e salvar', (tester) async {
      // ARRANGE
      final cartaoInicial = CartaoModel(
        id: 'c1', idUsuario: 'u1', nome: 'Cartão Antigo',
        valorFaturaAtual: 100.0, limiteCredito: 1500.0,
        dataFechamento: DateTime(2025, 9, 25), dataVencimento: DateTime(2025, 10, 5),
        dataCriacao: DateTime.now(), dataAtualizacao: DateTime.now(),
      );
      fakeViewModel.setSaveOutcome(true);

      await tester.pumpWidget(createTestableWidget(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAddEditCartaoDialog(context: context, cartao: cartaoInicial),
            child: const Text('Abrir'),
          );
        }),
      ));

      // ACT
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // ASSERT: Verifica se o dialog abriu no modo de edição com os dados corretos
      expect(find.text('Editar Cartão'), findsOneWidget);
      expect(find.text('Cartão Antigo'), findsOneWidget);
      expect(find.text('1500,00'), findsOneWidget); // Limite

      // ACT: Altera um campo e salva
      await tester.enterText(find.widgetWithText(TextFormField, 'Limite (R\$):'), '2500,00');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(fakeViewModel.salvarCartaoCalled, isTrue);
      expect(fakeViewModel.capturedCartao?.limiteCredito, 2500.0);
      expect(fakeViewModel.capturedCartao?.id, 'c1');
      expect(find.text('Editar Cartão'), findsNothing);
    });

    testWidgets('Deve mostrar SnackBar em caso de erro ao salvar', (tester) async {
      // ARRANGE
      fakeViewModel.setSaveOutcome(false); // Simula uma falha ao salvar
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

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome:'), 'Cartão com Erro');
      await tester.enterText(find.widgetWithText(TextFormField, 'Limite (R\$):'), '1000');
      
      await tester.tap(find.text('Salvar'));
      await tester.pump(); // Usa pump() para avançar um frame e mostrar a SnackBar

      // ASSERT
      expect(find.text('Erro ao salvar o cartão'), findsOneWidget);
      expect(find.text('Adicionar Cartão'), findsOneWidget); // O dialog não deve fechar
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
      // Encontra o botão e verifica se o callback `onPressed` é nulo (desabilitado)
      final salvarButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Salvar'));
      expect(salvarButton.onPressed, isNull);

      // ACT: Preenche apenas um campo
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome:'), 'Cartão');
      await tester.pumpAndSettle();

      // ASSERT: Botão ainda deve estar desabilitado
      final salvarButton2 = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Salvar'));
      expect(salvarButton2.onPressed, isNull);

      // ACT: Preenche o segundo campo obrigatório
      await tester.enterText(find.widgetWithText(TextFormField, 'Limite (R\$):'), '1000');
      await tester.pumpAndSettle();

      // ASSERT: Botão agora deve estar habilitado
      final salvarButton3 = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Salvar'));
      expect(salvarButton3.onPressed, isNotNull);
    });
  });
}
// integration_test/cartoes_flow_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:finbuddy/screens/Cartoes/cartoes_screen.dart';
import 'package:finbuddy/screens/Cartoes/viewmodel/cartoes_viewmodel.dart';
import 'package:finbuddy/shared/core/models/cartao_model.dart';

class FakeCartoesViewModel extends ChangeNotifier implements CartoesViewModel {
  final List<CartaoModel> _cartoes = [];
  final StreamController<List<CartaoModel>> _streamController = StreamController.broadcast();
  int _idCounter = 0;

  @override
  late Stream<List<CartaoModel>> cartoesStream;

  FakeCartoesViewModel() {
    cartoesStream = _streamController.stream;
    _emitCurrentState(); 
  }

  void _emitCurrentState() {
    _streamController.add(List.from(_cartoes));
  }

  @override
  Future<bool> salvarCartao(CartaoModel cartao) async {
    if (cartao.id == null) {
      _idCounter++;
      _cartoes.add(cartao.copyWith(id: 'fake_id_$_idCounter'));
    } else {
      final index = _cartoes.indexWhere((c) => c.id == cartao.id);
      if (index != -1) {
        _cartoes[index] = cartao;
      }
    }
    _emitCurrentState();
    notifyListeners();
    return true; 
  }

  @override
  Future<void> excluirCartao(String cartaoId) async {
    _cartoes.removeWhere((c) => c.id == cartaoId);
    _emitCurrentState();
    notifyListeners();
  }

  @override
  late final _repository;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo de Integração de Cartões: Adicionar e Deletar um Cartão', (WidgetTester tester) async {
    // ARRANGE
    // Cria a instância do nosso ViewModel falso
    final fakeViewModel = FakeCartoesViewModel();

    // "Infla" a CartoesScreen dentro de um MaterialApp e fornece o ViewModel falso
    await tester.pumpWidget(
      ChangeNotifierProvider<CartoesViewModel>.value(
        value: fakeViewModel,
        child: const MaterialApp(
          home: CartoesScreen(),
        ),
      ),
    );

    // --- ETAPA 1: VERIFICAR ESTADO INICIAL ---
    await tester.pump(); // Deixa a stream emitir o estado inicial
    expect(find.text('Meus Cartões'), findsOneWidget);
    expect(find.text('Nenhum cartão cadastrado.'), findsOneWidget);

    // --- ETAPA 2: ADICIONAR UM NOVO CARTÃO ---
    // ACT: Clica no botão para abrir o dialog de adição
    await tester.tap(find.text('Adicionar Cartão'));
    await tester.pumpAndSettle(); // Espera a animação do dialog

    // ACT: Preenche o formulário do novo cartão
    expect(find.text('Adicionar Cartão'), findsOneWidget); // Confirma que o dialog abriu
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome:'), 'Cartão de Integração');
    await tester.enterText(find.widgetWithText(TextFormField, 'Limite (R\$):'), '5000,00');
    
    // ACT: Clica em Salvar
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle(); // Espera o dialog fechar e a lista atualizar

    // ASSERT: Verifica se o novo cartão apareceu na tela principal
    expect(find.text('Nenhum cartão cadastrado.'), findsNothing);
    expect(find.text('Cartão de Integração'), findsOneWidget);
    expect(find.text('Limite: R\$ 5.000,00'), findsOneWidget);
    
    // --- ETAPA 3: DELETAR O CARTÃO CRIADO ---
    // ACT: Encontra e clica no ícone de deletar
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle(); // Espera o dialog de confirmação

    // ACT: Confirma a exclusão
    expect(find.text('Confirmar exclusão'), findsOneWidget);
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle(); // Espera o dialog fechar e a lista atualizar

    // ASSERT: Verifica se o cartão foi removido e a mensagem de lista vazia retornou
    expect(find.text('Cartão de Integração'), findsNothing);
    expect(find.text('Nenhum cartão cadastrado.'), findsOneWidget);
  });
}

extension on CartaoModel {
  CartaoModel copyWith({String? id}) {
    return CartaoModel(
      id: id ?? this.id,
      idUsuario: idUsuario,
      nome: nome,
      valorFaturaAtual: valorFaturaAtual,
      limiteCredito: limiteCredito,
      dataFechamento: dataFechamento,
      dataVencimento: dataVencimento,
      dataCriacao: dataCriacao,
      dataAtualizacao: dataAtualizacao,
    );
  }
}
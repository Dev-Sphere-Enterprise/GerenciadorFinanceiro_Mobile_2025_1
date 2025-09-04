import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finbuddy/screens/Aportes/dialog/add_edit_aporte_dialog.dart';
import 'package:finbuddy/screens/Aportes/viewmodel/aportes_viewmodel.dart';
import 'package:finbuddy/shared/core/models/aporte_meta_model.dart';
import 'package:finbuddy/shared/core/repositories/aportes_repository.dart';
import 'package:provider/provider.dart';

class FakeAportesViewModel extends ChangeNotifier implements AportesViewModel {
  bool salvarAporteCalled = false;
  bool _shouldReturnSuccess = true;
  Map<String, dynamic>? capturedData;

  void setSalvarAporteResult(bool success) {
    _shouldReturnSuccess = success;
  }

  @override
  Future<bool> salvarAporte({required double valor, required DateTime data, String? id}) async {
    salvarAporteCalled = true;
    capturedData = {'valor': valor, 'data': data, 'id': id};
    return _shouldReturnSuccess;
  }

  @override
  late final AportesRepository _repository;
  @override
  late Stream<List<AporteMetaModel>> aportesStream = Stream.value([]);
  @override
  Future<void> excluirAporte(String aporteId) async {}
  @override
  late String metaId;
  @override
  Future<void> recalcularMeta() async {}
}

void main() {
  late FakeAportesViewModel fakeViewModel;

  setUp(() {
    fakeViewModel = FakeAportesViewModel();
  });

  // Função auxiliar para criar o ambiente do teste
  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider<AportesViewModel>(
      create: (_) => fakeViewModel,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('showAddOrEditAporteDialog', () {
    testWidgets('Modo Adicionar: deve abrir, preencher e salvar com sucesso', (tester) async {
      // Arrange
      // Configura o ViewModel para retornar sucesso
      fakeViewModel.setSalvarAporteResult(true);

      // Cria um botão que, ao ser clicado, chamará a função do dialog
      await tester.pumpWidget(buildTestableWidget(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAddOrEditAporteDialog(context: context),
            child: const Text('Abrir Dialog'),
          );
        }),
      ));

      // Act: Abre o dialog
      await tester.tap(find.text('Abrir Dialog'));
      await tester.pumpAndSettle(); // Espera a animação do dialog terminar

      // Assert: Verifica se o dialog abriu corretamente no modo "Adicionar"
      expect(find.text('Adicionar Aporte'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // Act: Preenche o formulário
      await tester.enterText(find.byType(TextFormField), '250,50');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle(); // Espera a chamada assíncrona e o fechamento do dialog

      // Assert: Verifica se a função de salvar foi chamada e se o dialog fechou
      expect(fakeViewModel.salvarAporteCalled, isTrue);
      // Verifica se os dados corretos foram enviados (nota: o valor é convertido para double)
      expect(fakeViewModel.capturedData?['valor'], 250.50);
      expect(fakeViewModel.capturedData?['id'], isNull);
      expect(find.text('Adicionar Aporte'), findsNothing); // Dialog fechou
    });

    testWidgets('Modo Editar: deve abrir com dados preenchidos e salvar', (tester) async {
      // Arrange
      final aporteInicial = AporteMetaModel(
        id: 'aporte-123',
        idMeta: 'meta-abc',
        valor: 150.0,
        dataAporte: DateTime(2025, 9, 3),
        deletado: false,
      );
      fakeViewModel.setSalvarAporteResult(true);

      await tester.pumpWidget(buildTestableWidget(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAddOrEditAporteDialog(context: context, aporte: aporteInicial),
            child: const Text('Abrir Dialog'),
          );
        }),
      ));

      // Act
      await tester.tap(find.text('Abrir Dialog'));
      await tester.pumpAndSettle();

      // Assert: Verifica se o dialog está no modo "Editar" e com os dados corretos
      expect(find.text('Editar Aporte'), findsOneWidget);
      expect(find.text('150,0'), findsOneWidget); // valor inicial
      expect(find.text('03/09/2025'), findsOneWidget); // data inicial

      // Act: Edita o valor e salva
      await tester.enterText(find.byType(TextFormField), '175,25');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert: Verifica se a função de salvar foi chamada com os dados atualizados
      expect(fakeViewModel.salvarAporteCalled, isTrue);
      expect(fakeViewModel.capturedData?['valor'], 175.25);
      expect(fakeViewModel.capturedData?['id'], 'aporte-123'); // Verifica se o ID foi passado
      expect(find.text('Editar Aporte'), findsNothing); // Dialog fechou
    });

    testWidgets('Deve mostrar SnackBar em caso de erro ao salvar', (tester) async {
        // Arrange
        // Configura o ViewModel para retornar erro
        fakeViewModel.setSalvarAporteResult(false);

        await tester.pumpWidget(buildTestableWidget(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => showAddOrEditAporteDialog(context: context),
              child: const Text('Abrir Dialog'),
            );
          }),
        ));

        // Act
        await tester.tap(find.text('Abrir Dialog'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '300');
        await tester.tap(find.text('Salvar'));
        await tester.pump(); // Usa pump() para avançar um frame e mostrar a SnackBar

        // Assert
        expect(find.text('Erro ao salvar o aporte'), findsOneWidget);
        expect(find.text('Adicionar Aporte'), findsOneWidget); // O dialog não deve fechar
    });
  });
}
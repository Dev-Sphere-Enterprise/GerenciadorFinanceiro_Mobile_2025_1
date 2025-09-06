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
  Future<bool> salvarAporte({
    required double valor,
    required DateTime data,
    String? id,
  }) async {
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

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider<AportesViewModel>(
      create: (_) => fakeViewModel,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('showAddOrEditAporteDialog', () {
    testWidgets('Modo Adicionar: deve abrir, preencher e salvar com sucesso', (
      tester,
    ) async {
      fakeViewModel.setSalvarAporteResult(true);

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAddOrEditAporteDialog(context: context),
                child: const Text('Abrir Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar Aporte'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '250,50');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(fakeViewModel.salvarAporteCalled, isTrue);
      expect(fakeViewModel.capturedData?['valor'], 250.50);
      expect(fakeViewModel.capturedData?['id'], isNull);
      expect(find.text('Adicionar Aporte'), findsNothing);
    });

    testWidgets('Modo Editar: deve abrir com dados preenchidos e salvar', (
      tester,
    ) async {
      final aporteInicial = AporteMetaModel(
        id: 'aporte-123',
        idMeta: 'meta-abc',
        valor: 150.0,
        dataAporte: DateTime(2025, 9, 3),
        deletado: false,
        dataAtualizacao: DateTime(2025, 9, 3),
        dataCriacao: DateTime(2025, 9, 3),
      );
      fakeViewModel.setSalvarAporteResult(true);

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAddOrEditAporteDialog(
                  context: context,
                  aporte: aporteInicial,
                ),
                child: const Text('Abrir Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Aporte'), findsOneWidget);
      expect(find.text('150,0'), findsOneWidget);
      expect(find.text('03/09/2025'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '175,25');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(fakeViewModel.salvarAporteCalled, isTrue);
      expect(fakeViewModel.capturedData?['valor'], 175.25);
      expect(fakeViewModel.capturedData?['id'], 'aporte-123');
      expect(find.text('Editar Aporte'), findsNothing);
    });

    testWidgets('Deve mostrar SnackBar em caso de erro ao salvar', (
      tester,
    ) async {
      fakeViewModel.setSalvarAporteResult(false);

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAddOrEditAporteDialog(context: context),
                child: const Text('Abrir Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir Dialog'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '300');
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.text('Erro ao salvar o aporte'), findsOneWidget);
      expect(find.text('Adicionar Aporte'), findsOneWidget);
    });
  });
}

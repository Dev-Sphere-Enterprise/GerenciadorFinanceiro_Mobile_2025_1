import 'dart:async' as _i3;
import 'package:finbuddy/shared/core/models/ganho_model.dart' as _i4;
import 'package:finbuddy/shared/core/repositories/ganhos_repository.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

class MockGanhosRepository extends _i1.Mock implements _i2.GanhosRepository {
  MockGanhosRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<List<_i4.GanhoModel>> getGanhosFixosStream() =>
      (super.noSuchMethod(
            Invocation.method(#getGanhosFixosStream, []),
            returnValue: _i3.Stream<List<_i4.GanhoModel>>.empty(),
          )
          as _i3.Stream<List<_i4.GanhoModel>>);

  @override
  _i3.Future<void> addOrEditGanho(_i4.GanhoModel? ganho) =>
      (super.noSuchMethod(
            Invocation.method(#addOrEditGanho, [ganho]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> deleteGanho(String? ganhoId) =>
      (super.noSuchMethod(
            Invocation.method(#deleteGanho, [ganhoId]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> addGanhoPontual(_i4.GanhoModel? ganho) =>
      (super.noSuchMethod(
            Invocation.method(#addGanhoPontual, [ganho]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}

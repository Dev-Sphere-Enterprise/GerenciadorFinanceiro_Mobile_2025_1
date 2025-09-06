import 'dart:async' as _i4;
import 'package:finbuddy/shared/core/models/usuario_model.dart' as _i5;
import 'package:finbuddy/shared/core/repositories/auth_repository.dart' as _i3;
import 'package:firebase_auth/firebase_auth.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

class _FakeUserCredential_0 extends _i1.SmartFake
    implements _i2.UserCredential {
  _FakeUserCredential_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class MockAuthRepository extends _i1.Mock implements _i3.AuthRepository {
  MockAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<_i2.User?> get authStateChanges =>
      (super.noSuchMethod(
            Invocation.getter(#authStateChanges),
            returnValue: _i4.Stream<_i2.User?>.empty(),
          )
          as _i4.Stream<_i2.User?>);

  @override
  _i4.Future<_i2.UserCredential> signInWithEmailAndPassword(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#signInWithEmailAndPassword, [email, password]),
            returnValue: _i4.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#signInWithEmailAndPassword, [
                  email,
                  password,
                ]),
              ),
            ),
          )
          as _i4.Future<_i2.UserCredential>);

  @override
  _i4.Future<void> updateUserProfile(String? newName, DateTime? newDob) =>
      (super.noSuchMethod(
            Invocation.method(#updateUserProfile, [newName, newDob]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<_i5.UsuarioModel?> getCurrentUserProfile() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentUserProfile, []),
            returnValue: _i4.Future<_i5.UsuarioModel?>.value(),
          )
          as _i4.Future<_i5.UsuarioModel?>);

  @override
  _i4.Future<_i2.UserCredential> signInWithGoogle() =>
      (super.noSuchMethod(
            Invocation.method(#signInWithGoogle, []),
            returnValue: _i4.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#signInWithGoogle, []),
              ),
            ),
          )
          as _i4.Future<_i2.UserCredential>);

  @override
  _i4.Future<_i2.UserCredential> signUpWithEmailAndPassword({
    required String? email,
    required String? password,
    required String? nome,
    required DateTime? dob,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#signUpWithEmailAndPassword, [], {
              #email: email,
              #password: password,
              #nome: nome,
              #dob: dob,
            }),
            returnValue: _i4.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#signUpWithEmailAndPassword, [], {
                  #email: email,
                  #password: password,
                  #nome: nome,
                  #dob: dob,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.UserCredential>);

  @override
  _i4.Future<void> signOut() =>
      (super.noSuchMethod(
            Invocation.method(#signOut, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}

class MockUserCredential extends _i1.Mock implements _i2.UserCredential {
  MockUserCredential() {
    _i1.throwOnMissingStub(this);
  }
}

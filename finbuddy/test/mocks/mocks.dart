import 'package:firebase_auth/firebase_auth.dart'; // Adicione esta importação
import 'package:mockito/annotations.dart';
import 'package:finbuddy/shared/core/repositories/auth_repository.dart';

@GenerateMocks([AuthRepository, UserCredential])
void main() {}
import 'package:firebase_auth/firebase_auth.dart'; // Adicione esta importação
import 'package:mockito/annotations.dart';
import 'package:finbuddy/shared/core/repositories/auth_repository.dart';

// Adicione UserCredential à lista
@GenerateMocks([AuthRepository, UserCredential])
void main() {}
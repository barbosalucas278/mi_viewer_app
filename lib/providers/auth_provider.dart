import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 1. Provider para el servicio de almacenamiento seguro
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// 2. Provider para el estado de autenticación
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier(ref.watch(secureStorageProvider));
});

class AuthStateNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;

  AuthStateNotifier(this._storage) : super(false) {
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    state = token != null;
  }

  Future<void> login(String token) async {
    await _storage.write(key: 'access_token', value: token);
    state = true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    state = false;
  }
}
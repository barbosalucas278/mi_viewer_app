import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_viewer_app/providers/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_provider_test.mocks.dart';

// Genera el archivo de mocks con:
// flutter pub run build_runner build
@GenerateMocks([FlutterSecureStorage])
void main() {
  group('AuthStateNotifier', () {
    late MockFlutterSecureStorage mockStorage;
    late ProviderContainer container;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is false when no token is stored', () async {
      // Arrange
      when(mockStorage.read(key: 'access_token')).thenAnswer((_) async => null);

      // Act
      final notifier = container.read(authStateProvider.notifier);
      await Future.delayed(Duration.zero); // Espera a que se complete el _checkIfLoggedIn

      // Assert
      expect(notifier.state, isFalse);
    });

    test('initial state is true when a token is stored', () async {
      // Arrange
      when(mockStorage.read(key: 'access_token')).thenAnswer((_) async => 'fake_token');

      // Act
      final notifier = container.read(authStateProvider.notifier);
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state, isTrue);
    });

    test('login sets state to true and writes token to storage', () async {
      // Arrange
      final notifier = container.read(authStateProvider.notifier);
      const token = 'new_fake_token';
      when(mockStorage.write(key: 'access_token', value: token)).thenAnswer((_) async {});

      // Act
      await notifier.login(token);

      // Assert
      expect(notifier.state, isTrue);
      verify(mockStorage.write(key: 'access_token', value: token)).called(1);
    });

    test('logout sets state to false and deletes token from storage', () async {
      // Arrange
      final notifier = container.read(authStateProvider.notifier);
      when(mockStorage.delete(key: 'access_token')).thenAnswer((_) async {});

      // Act
      await notifier.logout();

      // Assert
      expect(notifier.state, isFalse);
      verify(mockStorage.delete(key: 'access_token')).called(1);
    });
  });
}
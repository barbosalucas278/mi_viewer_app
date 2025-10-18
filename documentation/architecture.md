# Arquitectura de la Aplicación con Riverpod

## 1. Elección de Riverpod

Para la gestión de estado y la inyección de dependencias de `mi_viewer_app`, se ha elegido **Riverpod**. Esta decisión se basa en los siguientes criterios:

-   **Simplicidad y Curva de Aprendizaje:** Riverpod es conocido por ser más fácil de entender que otras soluciones como BLoC, especialmente para desarrolladores que no están familiarizados con los streams complejos. Su API es declarativa y menos verbosa.
-   **Escalabilidad:** A pesar de su simplicidad, Riverpod es extremadamente potente y escalable. Permite organizar la lógica de negocio en unidades modulares y testeables llamadas "Providers", que pueden crecer en complejidad sin sacrificar la claridad del código.
-   **Seguridad en Tiempo de Compilación:** A diferencia de `Provider`, Riverpod es seguro en tiempo de compilación. Evita errores comunes en tiempo de ejecución, como el `ProviderNotFoundException`, ya que los proveedores son declarados globalmente y su existencia se verifica antes de que la aplicación se ejecute.
-   **Independencia del `BuildContext`:** Los proveedores de Riverpod no dependen del `BuildContext`, lo que significa que puedes acceder a tu estado desde cualquier parte de tu aplicación, no solo desde el árbol de widgets. Esto simplifica enormemente la lógica en las capas de negocio y de datos.

## 2. Conceptos Clave Utilizados

### `ProviderScope`
Es un widget que debe colocarse en la raíz de la aplicación (en `main.dart`). Almacena el estado de todos los proveedores y los hace accesibles desde cualquier lugar dentro de su alcance.

```dart
// lib/main.dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### `Provider`
Es el tipo más básico de proveedor. Se utiliza para exponer un valor inmutable o un objeto de servicio que no cambia con el tiempo. En nuestro caso, lo usamos para inyectar el servicio `FlutterSecureStorage`.

```dart
// lib/providers/auth_provider.dart
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
```

### `StateNotifierProvider`
Se utiliza para manejar estados que pueden cambiar. Se combina con una clase `StateNotifier` que contiene la lógica para modificar dicho estado. Es ideal para manejar el estado de autenticación del usuario.

```dart
// lib/providers/auth_provider.dart
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier(ref.watch(secureStorageProvider));
});

class AuthStateNotifier extends StateNotifier<bool> {
  // ... lógica para login, logout, etc.
}
```

### `StateProvider`
Es una versión simplificada para estados muy simples, como un booleano, un enum o un número. Lo utilizamos para gestionar el estado de la interfaz de usuario, como el índice de la página activa en la barra de navegación.

```dart
// lib/components/bottom_navigation_bar.dart
final pageIndexProvider = StateProvider<int>((ref) => 0);
```

### `ConsumerWidget` y `WidgetRef`
Para que un widget pueda escuchar y reaccionar a los cambios en un proveedor, debe ser un `ConsumerWidget` (o `ConsumerStatefulWidget`). Estos widgets proporcionan un objeto `WidgetRef` en su método `build`, que se utiliza para interactuar con los proveedores (`ref.watch` para escuchar cambios y `ref.read` para leer el valor una sola vez).

```dart
// lib/main.dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha los cambios en el estado de autenticación
    final isLoggedIn = ref.watch(authStateProvider);

    // ...
  }
}
```

## 3. Flujo de Autenticación con Riverpod

1.  **Inicio de la App:** `main.dart` envuelve la app en `ProviderScope`. `MyApp` (un `ConsumerWidget`) escucha `authStateProvider`.
2.  **Estado Inicial:** El `AuthStateNotifier` se inicializa y comprueba si existe un token en `FlutterSecureStorage` para determinar el estado de `isLoggedIn`.
3.  **Renderizado:** `MyApp` renderiza `LoginPage` o `NavigationMain` según el valor de `isLoggedIn`.
4.  **Login:** En `LoginPage`, al presionar "Iniciar Sesión", se llama a la función `_login`.
5.  **Actualización de Estado:** Si el login con Auth0 es exitoso, se llama a `ref.read(authStateProvider.notifier).login(token)`, lo que actualiza el estado `isLoggedIn` a `true`.
6.  **Re-renderizado Automático:** Como `MyApp` está escuchando (`ref.watch`) el `authStateProvider`, se reconstruye automáticamente y ahora muestra `NavigationMain`, completando el flujo de inicio de sesión de manera reactiva.
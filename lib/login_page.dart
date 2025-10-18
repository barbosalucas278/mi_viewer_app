import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_viewer_app/providers/auth_provider.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();

// ⚠️ Reemplazá con tus valores de Auth0
const String AUTH0_DOMAIN = 'lunabe.us.auth0.com';
const String AUTH0_CLIENT_ID = 'VxxhVtOD0RKv7yVSp3lqntFsCjdePIcp';
const String AUTH0_REDIRECT_URI = 'com.miapp://login-callback';
const String AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    try {
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          scopes: [
            'openid',
            'profile',
            'email',
            'offline_access',
          ],
        ),
      );

      if (result?.accessToken != null) {
        // Usamos el notifier para actualizar el estado de autenticación
        await ref.read(authStateProvider.notifier).login(result!.accessToken!);
      }
    } catch (e) {
      print("Error en login: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login con Auth0")),
      // --- UI MODIFICADA ---
      // Usamos una Column para poner un botón debajo del otro.
      body: Center(
        child: ElevatedButton(
          onPressed: () => _login(context, ref),
          child: const Text("Iniciar Sesión"),
        ),
      ),
    );
  }
}

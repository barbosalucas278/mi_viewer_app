import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mi_viewer_app/components/bottom_navigation_bar.dart';
import 'views/live_stream_page.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
final storage = FlutterSecureStorage();

// ⚠️ Reemplazá con tus valores de Auth0
const String AUTH0_DOMAIN = 'lunabe.us.auth0.com';
const String AUTH0_CLIENT_ID = 'VxxhVtOD0RKv7yVSp3lqntFsCjdePIcp';
const String AUTH0_REDIRECT_URI = 'com.miapp://login-callback';
const String AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<bool> checkIfLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null; // Si hay token, el usuario está logueado
  }

  Future<void> _login() async {
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
          ], // <-- AÑADE 'offline_access' PARA OBTENER UN REFRESH TOKEN
        ),
      );

      // --- SECCIÓN MODIFICADA ---
      // Guardamos todos los tokens que nos devuelve Auth0 de forma segura.
      if (result != null) {
        await storage.write(key: 'access_token', value: result.accessToken);
        await storage.write(key: 'id_token', value: result.idToken);
        await storage.write(key: 'refresh_token', value: result.refreshToken);
      }
      // --- FIN DE LA SECCIÓN MODIFICADA ---

      if (!mounted) return;

      // Navegar al stream
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationMain()),
      );
    } catch (e) {
      print("Error en login: $e");
      // Opcional: Mostrar un mensaje de error al usuario
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    }
  }

  // --- NUEVA FUNCIÓN ---
  // Esta función se ejecuta al presionar el nuevo botón.
  Future<void> _checkLoginStatus() async {
    final bool isLoggedIn = await checkIfLoggedIn();
    final String message = isLoggedIn
        ? '✅ El usuario ya está logueado.'
        : '❌ No hay sesión activa.';

    // Muestra el resultado en un SnackBar (una pequeña notificación en la parte inferior)
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // Oculta cualquier SnackBar anterior
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login con Auth0")),
      // --- UI MODIFICADA ---
      // Usamos una Column para poner un botón debajo del otro.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón original para iniciar sesión
            ElevatedButton(
              onPressed: _login,
              child: const Text("Iniciar Sesión"),
            ),
            const SizedBox(height: 20), // Un espacio entre los botones
            // Nuevo botón para verificar el estado de la sesión
            ElevatedButton(
              onPressed: _checkLoginStatus, // Llama a la nueva función
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blueGrey, // Un color diferente para distinguirlo
              ),
              child: const Text("Verificar Sesión"),
            ),
          ],
        ),
      ),
    );
  }
}

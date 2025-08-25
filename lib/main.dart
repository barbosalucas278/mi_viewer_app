import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mi_viewer_app/components/bottom_navigation_bar.dart';
import 'login_page.dart';
import 'views/live_stream_page.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkIfLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null; // Si hay token, el usuario está logueado
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Streaming con Auth0',
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkIfLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 👇 Si está logueado, va al stream, si no, al login
          return snapshot.data! ? const NavigationMain() : const LoginPage();
        },
      ),
    );
  }
}

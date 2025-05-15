import 'package:flutter/material.dart';
import 'package:inventario/screens/inventario_screen.dart';
import 'package:inventario/screens/menu_screen.dart';
import 'package:inventario/screens/movimiento_screen.dart';
import 'package:inventario/screens/nuevo_producto_screen.dart';
import 'package:inventario/screens/registro_screen.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'database/security_service.dart';
import 'models/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: SecurityService.getSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return snapshot.hasData ? MenuScreen() : LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/registro': (context) => RegistroScreen(),
        '/menu': (context) => MenuScreen(),
        '/inventario': (context) => InventarioScreen(),
        '/movimiento': (context) => MovimientoScreen(),
        '/nuevo-producto': (context) => const NuevoProductoScreen(),
      },
    );
  }
}

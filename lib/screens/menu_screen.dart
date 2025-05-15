import 'package:flutter/material.dart';
import '../database/security_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await SecurityService.deleteSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Ver Inventario'),
              onPressed: () => Navigator.pushNamed(context, '/inventario'),
            ),
            ElevatedButton(
              child: Text('Registrar Movimiento'),
              onPressed: () => Navigator.pushNamed(context, '/movimiento'),
            ),
            ElevatedButton(
              child: Text('Registrar Producto'),
              onPressed: () => Navigator.pushNamed(context, '/nuevo-producto'),
            ),
          ],
        ),
      ),
    );
  }
}
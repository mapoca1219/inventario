// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  Future<List<Map<String, dynamic>>> _cargarProductos() async {
    final db = await DatabaseHelper().database;
    return await db.query(
      DatabaseHelper.tablaProductos,
      orderBy: DatabaseHelper.colNombre,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          return;
        },
        child: FutureBuilder(
          future: _cargarProductos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final productos = snapshot.data!;
            
            if (productos.isEmpty) {
              return const Center(child: Text('No hay productos registrados'));
            }

            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ListTile(
                  title: Text(producto[DatabaseHelper.colNombre]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stock: ${producto[DatabaseHelper.colCantidad]}'),
                      Text('Últ. actualización: ${DateTime.parse(producto[DatabaseHelper.colFechaActualizacion]).toLocal()}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () => _verMovimientos(context, producto[DatabaseHelper.colId]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _verMovimientos(BuildContext context, int productoId) async {
    final db = await DatabaseHelper().database;
    final movimientos = await db.query(
      DatabaseHelper.tablaMovimientos,
      where: '${DatabaseHelper.colProductoId} = ?',
      whereArgs: [productoId],
      orderBy: DatabaseHelper.colFecha,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de movimientos'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = movimientos[index];
              return ListTile(
                title: Text('${movimiento[DatabaseHelper.colTipo].toString().toUpperCase()}'),
                subtitle: Text('Cantidad: ${movimiento[DatabaseHelper.colCantidad]}'),
                trailing: Text(DateTime.parse(movimiento[DatabaseHelper.colFecha] as String).toLocal().toString()),
              );
            },
          ),
        ),
      ),
    );
  }
}
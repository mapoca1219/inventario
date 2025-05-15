import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class NuevoProductoScreen extends StatefulWidget {
  const NuevoProductoScreen({super.key});

  @override
  _NuevoProductoScreenState createState() => _NuevoProductoScreenState();
}

class _NuevoProductoScreenState extends State<NuevoProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();

  Future<void> _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      try {
        final db = await DatabaseHelper().database;
        
        await db.insert('productos', {
          'nombre': _nombreController.text,
          'cantidad': int.parse(_cantidadController.text),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Inicial',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Campo obligatorio';
                  if (int.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _guardarProducto,
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
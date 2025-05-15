import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class MovimientoScreen extends StatefulWidget {
  const MovimientoScreen({super.key});

  @override
  _MovimientoScreenState createState() => _MovimientoScreenState();
}

class _MovimientoScreenState extends State<MovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoController = TextEditingController();
  final _cantidadController = TextEditingController();
  bool _esEntrada = true;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _productosFiltrados = [];

  void _filtrarProductos(String query) {
    setState(() {
      _productosFiltrados = _productos
          .where((producto) => producto[DatabaseHelper.colNombre]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final db = await DatabaseHelper().database;
    final productos = await db.query(
      DatabaseHelper.tablaProductos,
      columns: [DatabaseHelper.colId, DatabaseHelper.colNombre, DatabaseHelper.colCantidad],
    );
    setState(() {
      _productos = productos;
      _productosFiltrados = productos;
    });
  }

  Future<void> _registrarMovimiento() async {
    if (_formKey.currentState!.validate() && _productosFiltrados.isNotEmpty) {
      final productoSeleccionado = _productosFiltrados.firstWhere(
        (p) => p[DatabaseHelper.colNombre] == _productoController.text,
        orElse: () => {},
      );

      if (productoSeleccionado.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Producto no encontrado!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final db = await DatabaseHelper().database;
      final cantidad = int.parse(_cantidadController.text);

      try {
        await db.transaction((txn) async {
          // Actualizar stock
          await txn.update(
            DatabaseHelper.tablaProductos,
            {
              DatabaseHelper.colCantidad: productoSeleccionado[DatabaseHelper.colCantidad] + (_esEntrada ? cantidad : -cantidad),
              DatabaseHelper.colFechaActualizacion: DateTime.now().toIso8601String(),
            },
            where: '${DatabaseHelper.colId} = ?',
            whereArgs: [productoSeleccionado[DatabaseHelper.colId]],
          );

          // Registrar movimiento
          await txn.insert(
            DatabaseHelper.tablaMovimientos,
            {
              DatabaseHelper.colProductoId: productoSeleccionado[DatabaseHelper.colId],
              DatabaseHelper.colTipo: _esEntrada ? 'entrada' : 'salida',
              DatabaseHelper.colCantidad: cantidad,
              DatabaseHelper.colFecha: DateTime.now().toIso8601String(),
            },
          );
        });
        Navigator.pop(context, true); // Envía señal de actualización
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
      appBar: AppBar(title: const Text('Registro de Movimientos')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _productosFiltrados.where((producto) => producto['nombre']
                      .toString()
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (producto) => _productoController.text = producto['nombre'],
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Producto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: (value) => value == null ? 'Seleccione un producto' : null,
                    items: _productos.map((producto) {
                      return DropdownMenuItem<int>(
                        value: producto[DatabaseHelper.colId],
                        child: Text(
                          producto[DatabaseHelper.colNombre],
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final productoSeleccionado = _productos.firstWhere(
                        (p) => p[DatabaseHelper.colId] == value,
                        orElse: () => {},
                      );
                      
                      if (productoSeleccionado.isNotEmpty) {
                        _productoController.text = productoSeleccionado[DatabaseHelper.colNombre];
                      }
                    },
                    hint: const Text('Seleccione un producto'),
                    isExpanded: true,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final producto = options.elementAt(index);
                            return ListTile(
                              title: Text(producto['nombre']),
                              subtitle: Text('Stock: ${producto['cantidad']}'),
                              onTap: () => onSelected(producto),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Campo obligatorio';
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) return 'Cantidad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(_esEntrada ? 'Entrada de mercancía' : 'Salida de mercancía'),
                value: _esEntrada,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                onChanged: (value) => setState(() => _esEntrada = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Registrar Movimiento', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
                onPressed: _registrarMovimiento,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
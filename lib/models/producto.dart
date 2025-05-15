class Producto {
  final int id;
  final String nombre;
  final int cantidad;
  final DateTime fechaActualizacion;

  Producto({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.fechaActualizacion,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      cantidad: map['cantidad'],
      fechaActualizacion: DateTime.parse(map['fecha_actualizacion']),
    );
  }
}
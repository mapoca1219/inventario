class Usuario {
  final int id;
  final String usuario;
  final String contrasena;

  Usuario({
    required this.id,
    required this.usuario,
    required this.contrasena,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      usuario: map['usuario'],
      contrasena: map['contrasena'],
    );
  }
}
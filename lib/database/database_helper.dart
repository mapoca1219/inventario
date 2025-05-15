// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const _databaseName = "inventario.db";
  static const _databaseVersion = 1;

  // Tablas y columnas
  static const tablaUsuarios = 'usuarios';
  static const tablaProductos = 'productos';
  static const tablaMovimientos = 'movimientos';

  static const colId = 'id';
  static const colUsuario = 'usuario';
  static const colContrasena = 'contrasena';
  static const colNombre = 'nombre';
  static const colCantidad = 'cantidad';
  static const colFechaActualizacion = 'fecha_actualizacion';
  static const colProductoId = 'producto_id';
  static const colTipo = 'tipo';
  static const colFecha = 'fecha';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Crear tabla usuarios
    await db.execute('''
      CREATE TABLE $tablaUsuarios (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUsuario TEXT UNIQUE NOT NULL,
        $colContrasena TEXT NOT NULL
      )
    ''');

    // Crear tabla productos
    await db.execute('''
      CREATE TABLE $tablaProductos (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colNombre TEXT NOT NULL,
        $colCantidad INTEGER NOT NULL,
        $colFechaActualizacion TEXT NOT NULL
      )
    ''');

    // Crear tabla movimientos
    await db.execute('''
      CREATE TABLE $tablaMovimientos (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colProductoId INTEGER NOT NULL,
        $colTipo TEXT NOT NULL,
        $colCantidad INTEGER NOT NULL,
        $colFecha TEXT NOT NULL,
        FOREIGN KEY ($colProductoId) REFERENCES $tablaProductos($colId)
      )
    ''');

    // Insertar usuario admin
    final hash = BCrypt.hashpw('admin123', BCrypt.gensalt());
    await db.insert(tablaUsuarios, {
      colUsuario: 'admin',
      colContrasena: hash,
    });
  }

  Future<int> insertarUsuario(String usuario, String contrasena) async {
    final db = await database;
    final hash = BCrypt.hashpw(contrasena, BCrypt.gensalt());
    return await db.insert(tablaUsuarios, {
      colUsuario: usuario,
      colContrasena: hash,
    });
  }

  Future<bool> validarUsuario(String usuario, String contrasena) async {
    final db = await database;
    final result = await db.query(
      tablaUsuarios,
      where: '$colUsuario = ?',
      whereArgs: [usuario],
    );

    if (result.isEmpty) return false;
    return BCrypt.checkpw(contrasena, result.first[colContrasena] as String);
  }
}
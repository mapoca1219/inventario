import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  List<Map<String, dynamic>> _inventario = [];

  List<Map<String, dynamic>> get inventario => _inventario;

  void actualizarInventario(List<Map<String, dynamic>> nuevosDatos) {
    _inventario = nuevosDatos;
    notifyListeners();
  }
}
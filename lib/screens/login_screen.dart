import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();
      final usuarioValido = await dbHelper.validarUsuario(
        _usuarioController.text,
        _contrasenaController.text,
      );

      if (usuarioValido) {
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Ingresar'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/registro'),
                child: const Text('Crear cuenta nueva'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
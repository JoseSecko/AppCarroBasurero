import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'drawer_menu.dart';  // Asegúrate de importar el DrawerMenu

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido/a'),
      ),
      drawer: DrawerMenu(),  // Usa el DrawerMenu aquí
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡Bienvenido/a, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Usuario'}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

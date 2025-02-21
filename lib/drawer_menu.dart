import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reporte_page.dart';
import 'rutas.dart';
import 'foro.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Usuario Anónimo'),
            accountEmail: Text(user?.email ?? 'No disponible'),
            currentAccountPicture: CircleAvatar(
              child: Text(user?.displayName?.substring(0, 1) ?? 'U'),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a HomePage si no estás ya allí
            },
          ),
          ListTile(
            leading: Icon(Icons.report), // Icono representativo para reportes
            title: Text('Reportar Problemas'),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportPage()), // Navega a la página de reportes
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.report), // Icono representativo para reportes
            title: Text('Horario'),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrashRouteMapPage()), // Navega a la página de reportes
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.forum), // Icono para el foro
            title: Text('Foro de la Comunidad'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForoComunidadScreen()), // Redirige a foro.dart
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a la página de configuración
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Cerrar sesión'),
            onTap: () async {
              Navigator.pop(context); // Cierra el menú drawer antes de proceder

              await FirebaseAuth.instance.signOut(); // Espera a que la sesión se cierre correctamente

              // Después de cerrar sesión, elimina todas las rutas y navega a la pantalla de inicio de sesión
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),

        ],
      ),
    );
  }
}

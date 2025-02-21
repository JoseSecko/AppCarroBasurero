import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'registro_localizacion_page.dart'; // Asegúrate de importar la página de registro de localización
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage();
            } else {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Usuarios').doc(user.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> docSnapshot) {
                  if (docSnapshot.connectionState == ConnectionState.done) {
                    // Asegurarse de que el snapshot y los datos no son nulos
                    if (docSnapshot.data != null && docSnapshot.data!.exists) {
                      // Asegurarse de hacer un cast seguro de los datos a Map<String, dynamic>
                      Map<String, dynamic>? data = docSnapshot.data!.data() as Map<String, dynamic>?;

                      // Comprobar si la clave 'posicion' no existe en los datos
                      if (data != null && !data.containsKey('location')) {
                        return registro_localizacion_page(); // Redirige a la página de registro de localización
                      } else {
                        return HomePage(); // El usuario tiene la clave 'posicion', continuar a HomePage
                      }
                    } else {
                      return registro_localizacion_page(); // No hay datos, asumir que necesita registro de localización
                    }
                  } else {
                    return CircularProgressIndicator(); // Aún cargando datos
                  }
                },
              );
            }
          }
          return CircularProgressIndicator(); // Muestra un indicador de carga mientras se verifica el estado de autenticación
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'home_residente.dart';
import 'registro_localizacion_page.dart'; 
import 'home_conductor.dart'; // Asegúrate de importar la pantalla del conductor
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
                    if (docSnapshot.hasData && docSnapshot.data!.exists) {
                      Map<String, dynamic>? data = docSnapshot.data!.data() as Map<String, dynamic>?;

                      if (data != null) {
                        String? rol = data['rol']; // Obtiene el rol del usuario

                        if (rol == "conductor") {
                          return HomeConductorPage(); // Página para conductores
                        } else {
                          if (!data.containsKey('location')) {
                            return registro_localizacion_page(); // Registro de ubicación para residentes
                          } else {
                            return HomeResidentePage(); // Página del residente
                          }
                        }
                      }
                    }
                    return registro_localizacion_page(); // Si no hay datos, asumir que es nuevo
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            }
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}


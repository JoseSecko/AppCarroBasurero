import 'package:app_carro_basurero/home_residente.dart'; // Pantalla del residente
import 'package:app_carro_basurero/home_conductor.dart'; // Pantalla del conductor
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false; // Para deshabilitar botón y oscurecer la pantalla

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLoading ? Colors.black.withOpacity(0.7) : Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'image/carro_basurero.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 60.0),
                Text(
                  'Bienvenido',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      setState(() => isLoading = true);
                      await signInWithGoogle(context);
                      setState(() => isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('image/google_icon.png', height: 18.0),
                        SizedBox(width: 10.0),
                        Text('Iniciar sesión con Google', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) 
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Oscurece la pantalla
                child: Center(child: CircularProgressIndicator()), // Indicador de carga
              ),
            ),
        ],
      ),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Asegura que la sesión anterior se cierre

    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("El usuario canceló el login.");
        return;
      }

      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference userRef = FirebaseFirestore.instance.collection('Usuarios').doc(user.uid);
        DocumentSnapshot snapshot = await userRef.get();

        if (!snapshot.exists) {
          // Usuario nuevo: pedirle que elija un rol
          await userRef.set({
            'username': user.displayName ?? 'Usuario Anónimo',
            'email': user.email ?? 'Sin Email',
            'rol': 'residente', // Aquí puedes agregar lógica para elegir el rol
          });
          print("Usuario agregado a Firestore.");
          navigateToScreen(context, 'residente'); // Lo envía a la pantalla de residente por defecto
        } else {
          String rol = snapshot['rol'];
          print("Usuario existente con rol: $rol");
          navigateToScreen(context, rol); // Lo redirige a la pantalla según su rol
        }
      }
    } catch (e) {
      print("Error durante el inicio de sesión: $e");
    }
  }

  void navigateToScreen(BuildContext context, String rol) {
    if (rol == 'residente') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeResidentePage()));
    } else if (rol == 'conductor') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeConductorPage()));
    } else {
      print("Rol desconocido: $rol");
    }
  }
}

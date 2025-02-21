import 'package:app_carro_basurero/home_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset('image/carro_basurero.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,), // Puedes reemplazarlo con tu propia imagen
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
              height: 40.0, // Puedes ajustar la altura según tus necesidades
              child: ElevatedButton(
                onPressed: () {
                  signInWithGoogle(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('image/google_icon.png', height: 18.0), // Imagen del ícono de Google
                    SizedBox(width: 10.0),
                    Text('Iniciar sesión con Google', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Asegura la sesión anterior se cierre

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

      if (userCredential.user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userCredential.user!.uid)
            .get();

        if (!snapshot.exists) {
          print("Usuario nuevo detectado, procediendo a agregar.");
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(userCredential.user!.uid)
              .set({
                'username': userCredential.user!.displayName ?? 'Usuario Anónimo',
                'email': userCredential.user!.email ?? 'Sin Email',
              });
          print("Usuario agregado a Firestore.");
        } else {
          print("Usuario existente, no se agregan datos.");
        }
      }
    } catch (e) {
      print("Se produjo un error durante el inicio de sesión: $e");
    }
  }

}


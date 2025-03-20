import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'localizacion_page.dart';

class HomeConductorPage extends StatelessWidget {
  const HomeConductorPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> getConductorData() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return null;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('camiones').get();

    for (var doc in querySnapshot.docs) {
      if (doc.data() is Map<String, dynamic>) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['email'] == email) {
          return {'placa': doc.id, ...data}; // Agrega la placa como parte de los datos
        }
      }
    }
    return null; // Si no encuentra el conductor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inicio - Conductor")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getConductorData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text("No se encontraron datos del conductor"));
          }

          var data = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Placa: ${data['placa']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Conductor: ${data['conductor']}", style: TextStyle(fontSize: 16)),
                Text("Marca: ${data['marca']}", style: TextStyle(fontSize: 16)),
                Text("Año: ${data['year']}", style: TextStyle(fontSize: 16)),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocalizacionPage()),
                    );
                  },
                  child: Text("Iniciar Localización"),
                ),

                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reportes'); // Asegúrate de definir esta ruta
                  },
                  child: Text("Reportes"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

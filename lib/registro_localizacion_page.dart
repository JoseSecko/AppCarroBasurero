import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_residente.dart'; 

class registro_localizacion_page extends StatefulWidget {
  @override
  _registro_localizacion_pageState createState() => _registro_localizacion_pageState();
}

class _registro_localizacion_pageState extends State<registro_localizacion_page> {
  final LatLng _initialPosition = LatLng(-17.433402, -66.111433); // Coordenadas iniciales
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _saveLocation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor elija su ubicación', style: TextStyle(color: Colors.red)),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (userId != null) {
      // Usar set con SetOptions para mezclar los datos en lugar de reemplazarlos
      await FirebaseFirestore.instance.collection('Usuarios').doc(userId).set({
        'location': GeoPoint(_selectedPosition!.latitude, _selectedPosition!.longitude),
      }, SetOptions(merge: true)); // Asegúrate de agregar SetOptions(merge: true)

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeResidentePage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Ubicación')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              onTap: (position) {
                setState(() {
                  _selectedPosition = position;
                });
              },
              markers: _selectedPosition == null ? {} : {
                Marker(
                  markerId: MarkerId("home"),
                  position: _selectedPosition!,
                )
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveLocation,
              child: Text('Guardar Ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}

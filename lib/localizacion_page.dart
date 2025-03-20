import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocalizacionPage extends StatefulWidget {
  @override
  _LocalizacionPageState createState() => _LocalizacionPageState();
}

class _LocalizacionPageState extends State<LocalizacionPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  DatabaseReference? _databaseReference;
  User? _user;

  @override
  void initState() {
    super.initState();
    _initFirebase();
    _determinePosition();
  }

  Future<void> _initFirebase() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://proyecto-carro-basurero-default-rtdb.firebaseio.com",
      );

      _databaseReference = database.ref().child("ubicaciones").child(_user!.uid);

      print("Firebase inicializado correctamente. UID: ${_user!.uid}");
    } else {
      print("Error: Usuario no autenticado");
    }
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
}


  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Obtiene la ubicación actual
    Position position = await Geolocator.getCurrentPosition();
    _updatePosition(position);

    // Escucha cambios en la ubicación y envía a Firebase
    Geolocator.getPositionStream().listen((Position newPosition) {
      _updatePosition(newPosition);
    });
  }

  void _updatePosition(Position position) {
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (_databaseReference == null) {
      print("Error: _databaseReference es null, no se puede enviar la ubicación.");
      return;
    }

    _databaseReference!.push().set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    }).then((_) {
      print("Ubicación enviada correctamente a Firebase");
    }).catchError((error) {
      print("Error al enviar datos a Firebase: $error");
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubicación en Tiempo Real')),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 17.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              circles: {
                Circle(
                  circleId: CircleId('user_location'),
                  center: _currentPosition!,
                  radius: 30,
                  fillColor: Colors.blue.withOpacity(0.5),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
              },
            ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialReportLocation;
  final Function(LatLng) onLocationSelected;
  final Function(LatLng) onUserLocationObtained;

   MapScreen({this.initialReportLocation, required this.onLocationSelected, required this.onUserLocationObtained});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  LatLng? _reportLocation;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _reportLocation = widget.initialReportLocation;
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Detener la actualización de la ubicación al salir
    super.dispose();
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Obtener ubicación en tiempo real
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = newLocation;
      });

      widget.onUserLocationObtained(newLocation);

      // Mover la cámara solo la primera vez
      if (_mapController != null && _reportLocation == null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    });
  }

  void _selectReportLocation(LatLng position) {
    setState(() {
      _reportLocation = position; // Guardar ubicación del reporte
    });
    widget.onLocationSelected(position);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _reportLocation ?? _userLocation ?? LatLng(-17.3935, -66.157),
          zoom: 15,
        ),
        myLocationEnabled: true, // Punto azul del usuario
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          if (_reportLocation != null)
            Marker(
              markerId: MarkerId("reportLocation"),
              position: _reportLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
        },
        onTap: _selectReportLocation, // Marcar ubicación del reporte al tocar el mapa
      ),
    );
  }
}

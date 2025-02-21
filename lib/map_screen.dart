import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final Function(LatLng) onUserLocationObtained;

  MapScreen({required this.onLocationSelected, required this.onUserLocationObtained});

  @override
  _MapScreenState createState() => _MapScreenState();
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition();
}


class _MapScreenState extends State<MapScreen> {
  LatLng _initialPosition = LatLng(-17.7833, -63.1821);
  GoogleMapController? _controller;
  bool _isMapExpanded = false;
  LatLng? _userLocation;
  LatLng? _reportLocation;
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      widget.onUserLocationObtained(userLocation);
      setState(() {
        _userLocation = userLocation;
        _initialPosition = userLocation;
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(userLocation));
    } catch (e) {
      print('Could not get the location: $e');
    }
  }


  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _getCurrentLocation().catchError((error) {
      print('Error getting user location: $error');
    });
  }


  void _toggleMapSize() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
  }
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  // Llama a esta función para establecer la ubicación del usuario al cargar
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isMapExpanded ? MediaQuery.of(context).size.height : 300,
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            onTap: (LatLng position) {
              setState(() {
                _reportLocation = position;
                _controller?.animateCamera(CameraUpdate.newLatLng(position));
              });
              widget.onLocationSelected(position);
            },
            markers: {
              if (_reportLocation != null) Marker(
                markerId: MarkerId("reportLocation"),
                position: _reportLocation!,
                draggable: true,
                onDragEnd: (newPosition) {
                  print(newPosition.latitude);
                  print(newPosition.longitude);
                },
              ),
            },
                    myLocationEnabled: true,  // Muestra la ubicación actual del usuario como un punto azul.
                    myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: _toggleMapSize,
              child: Icon(Icons.zoom_out_map),
            ),
          )
        ],
      ),
    );
  }
}

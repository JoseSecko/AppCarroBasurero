import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrashRouteMapPage extends StatefulWidget {
  @override
  _TrashRouteMapPageState createState() => _TrashRouteMapPageState();
}

class _TrashRouteMapPageState extends State<TrashRouteMapPage> {
  GoogleMapController? mapController;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String? selectedBarrio;
  List<DropdownMenuItem<String>> barriosList = [];
  Set<Polyline> _polylines = Set(); // Set to hold the polylines

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    fetchBarrios();
  }

  void fetchBarrios() async {
    var barrios = await db.collection('ZonaCercado').get();
    for (var barrio in barrios.docs) {
      barriosList.add(DropdownMenuItem(
        value: barrio.id,
        child: Text(barrio.id),
      ));
    }
    if (barriosList.isNotEmpty) {
      selectedBarrio = barriosList[0].value;
    }
    setState(() {});
  }

  void showRoute(String barrioId) async {
  var routeInfo = await db.collection('ZonaCercado').doc(barrioId).get();
  if (routeInfo.exists) {
    var latitudes = List<double>.from(routeInfo.data()!['coordenadaslatitudRuta']);
    var longitudes = List<double>.from(routeInfo.data()!['coordenadaslongitudRuta']);

    List<LatLng> routePoints = [];
    for (int i = 0; i < latitudes.length; i++) {
      routePoints.add(LatLng(latitudes[i], longitudes[i]));
    }
     // Define el fondo negro de la polilínea
    Polyline blackBackground = Polyline(
      polylineId: PolylineId("bg_$barrioId"),
      visible: true,
      points: routePoints,
      width: 8,
      color: Colors.black,
    );

    // Define la polilínea amarilla discontinua
    Polyline yellowDashed = Polyline(
      polylineId: PolylineId(barrioId),
      visible: true,
      points: routePoints,
      width: 2,
      color: Colors.yellow,
      patterns: <PatternItem>[
        PatternItem.dash(20),
        PatternItem.gap(10)
      ]
    );
    setState(() {
      _polylines.clear(); // Limpia las polilíneas existentes
      _polylines.add(blackBackground);
      _polylines.add(yellowDashed);
    });

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutas de Basura'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(-17.43978709662017, -66.13120327615485), // Ajusta a tus necesidades
                zoom: 12.0,
              ),
              polylines: _polylines, // Agrega las polilíneas al mapa
            ),
          ),
          DropdownButton<String>(
            value: selectedBarrio,
            onChanged: (value) {
              setState(() {
                selectedBarrio = value;
                showRoute(value!);
              });
            },
            items: barriosList,
          ),
        ],
      ),
    );
  }
}

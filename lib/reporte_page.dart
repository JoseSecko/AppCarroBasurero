import 'dart:io';
import 'package:app_carro_basurero/home_residente.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'map_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  String? _type;
  String? _description;
  XFile? _image;
  LatLng? _userLocation;
  LatLng? _reportLocation;
  final picker = ImagePicker();
  bool _isSubmitting = false; // Estado para bloquear la pantalla y deshabilitar el botón

  Future<void> getImage() async {
    var source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Elige el origen de la imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    }
  }
  Future<Map<String, dynamic>> obtenerDatosExifDesdeCloudRun(String imageUrl) async {
  try {
    final url = Uri.parse('https://verificador-imagen-835858854447.southamerica-east1.run.app');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'imageUrl': imageUrl}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("📸 Metadatos recibidos desde Cloud Run:");
      print(data);

      if (data['esValida'] == true && data['datos'] != null) {
        return Map<String, dynamic>.from(data['datos']);
      }
    } else {
      print("❌ Respuesta con error: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error al llamar a Cloud Run: $e");
  }

  return {};
}



  Future<String?> uploadFile(XFile? file) async {
    if (file == null) return null;
    String fileName = 'fotos_de_reportes/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    firebase_storage.UploadTask uploadTask = ref.putFile(File(file.path));
    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Debes subir una imagen para el reporte.'))
        );
        return;
      }

      if (_reportLocation == null || _userLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Ubicación no determinada.'))
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Usuario no autenticado.'))
        );
        return;
      }

      setState(() {
        _isSubmitting = true; // Bloquea la pantalla y muestra el indicador de carga
      });

      String? imageUrl = await uploadFile(_image);
      Map<String, dynamic> exif = await obtenerDatosExifDesdeCloudRun(imageUrl!);
      print('🛰️ Metadatos recibidos desde Cloud Run:');
      print(exif);
      String userId = user.uid;
      DateTime timestamp = DateTime.now();

      await FirebaseFirestore.instance.collection('Reportes').add({
        'type': _type,
        'description': _description,
        'image': imageUrl,
        'reportLocation': GeoPoint(_reportLocation!.latitude, _reportLocation!.longitude),
        'userLocation': GeoPoint(_userLocation!.latitude, _userLocation!.longitude),
        'userId': userId,
        'timestamp': timestamp,
        'make': exif['Make'] ?? '',
        'model': exif['Model'] ?? '',
        'dateTime': exif['DateTime'] ?? '',
        'imageGpsLocation': exif['Latitude'] != null && exif['Longitude'] != null
          ? GeoPoint(exif['Latitude'], exif['Longitude'])
          : null, // 🛰️ guarda solo si hay coordenadas
        
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte enviado correctamente'))
      );

      setState(() {
        _isSubmitting = false; // Desbloquea la pantalla
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeResidentePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reportar un Problema')),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSubmitting, // Bloquea interacciones si está enviando
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value: _type,
                    hint: Text('Selecciona el tipo de problema'),
                    onChanged: (value) => setState(() => _type = value),
                    items: <String>[
                      'Contenedores Llenos', 'Basura en la Calle', 'Falta de Servicio', 'Canales Llenos', 'Colapso de Alcantarillas'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descripción adicional',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _description = value),
                    initialValue: _description,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator: (value) => value!.isEmpty ? 'Por favor ingresa una descripción' : null,
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : getImage, // Deshabilitado mientras envía
                    child: Text('Subir Foto'),
                  ),
                  if (_image != null) Image.file(File(_image!.path)),
                  SizedBox(height: 10),

                  MapScreen(
                    initialReportLocation: _reportLocation,
                    onLocationSelected: (LatLng reportLocation) {
                      setState(() {
                        _reportLocation = reportLocation;
                      });
                    },
                    onUserLocationObtained: (LatLng userLocation) {
                      setState(() {
                        _userLocation = userLocation;
                      });
                    },
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : submitReport, // Deshabilita mientras envía
                    child: Text('Enviar Reporte'),
                  ),
                ],
              ),
            ),
          ),

          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Oscurece la pantalla
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:geocoding/geocoding.dart';
//import 'vehicles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: LoginPage(),
    );
  }
}

//login form
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim());
                      // Navigate to the home screen after successful login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyCustomWidget()),
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        _errorMessage = e.message;
                      });
                    }
                  }
                },
                child: Text('Login'),
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// open map form

List<LatLng> parkingSpots = [
  LatLng(51.260197, 4.402771),
  LatLng(51.280197, 4.422771),
  LatLng(51.265197, 4.412771),
  LatLng(51.275197, 4.402771),
  LatLng(51.255197, 4.432771),
  LatLng(51.290197, 4.402771),
  LatLng(51.240197, 4.422771),
];

class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.260197, 4.402771),
        zoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            for (var parkingSpot in parkingSpots)
              Marker(
                point: parkingSpot,
                width: 50,
                height: 50,
                builder: (context) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationFormPage(
                          parkingSpot: parkingSpot,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    child: Icon(
                      Icons.local_parking,
                      color: Colors.green,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

//reserveringspagina
class ReservationFormPage extends StatelessWidget {
  final LatLng parkingSpot;

  ReservationFormPage({required this.parkingSpot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserveringsformulier'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Straatnaam: ${getStreetName()}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              'Tijdstip reserveren:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tijdstip',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Voeg hier de logica toe om de reservering te verwerken
              },
              child: Text('Reserveer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getStreetName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        parkingSpot.latitude,
        parkingSpot.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String streetName = placemark.street!;
        return streetName;
      }
    } catch (e) {
      print('Fout bij het ophalen van de straatnaam: $e');
    }
    return 'Onbekende straatnaam';
  }
}

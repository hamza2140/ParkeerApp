import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'vehicles.dart'; // importeer de klasse "Vehicle

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = "";
  String _password = "";
  String _errorMessage = "";

  void _submit() {
    if (_username == 'hamza' && _password == 'parkeer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyCustomWidget()),
      );
    } else {
      setState(() {
        _errorMessage = 'Ongeldige gebruikersnaam of wachtwoord';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Gebruikersnaam'),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Wachtwoord'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Inloggen'),
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.260197, 4.402771),
        zoom: 12,
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
          sourceTextStyle: const TextStyle(fontSize: 2),
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(51.260197, 4.402771),
              width: 50,
              height: 50,
              builder: (context) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50.0,
                ),
              ),
            ),
            Marker(
              point: LatLng(51.280197, 4.422771),
              width: 50,
              height: 50,
              builder: (context) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 50.0,
                ),
              ),
            ),
            Marker(
              point: LatLng(52.260197, 4.462771),
              width: 50,
              height: 50,
              builder: (context) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 50.0,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

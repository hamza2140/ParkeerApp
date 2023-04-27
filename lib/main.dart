import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vehicles.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: LoginPage(auth: _auth),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _username;
  String? _password;
  String? _errorMessage;
  bool _isLoginForm = true;
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential userCredential;
        if (_isLoginForm) {
          userCredential = await widget.auth.signInWithEmailAndPassword(
              email: _username!, password: _password!);
        } else {
          userCredential = await widget.auth.createUserWithEmailAndPassword(
              email: _username!, password: _password!);
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyCustomWidget()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = 'Ongeldige gebruikersnaam of wachtwoord';
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void _toggleFormMode() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Gebruikersnaam'),
                  validator: (value) =>
                      value!.isEmpty ? 'Gebruikersnaam is verplicht' : null,
                  onSaved: (value) => _username = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Wachtwoord'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Wachtwoord is verplicht' : null,
                  onSaved: (value) => _password = value,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isLoginForm ? 'Inloggen' : 'Registreren'),
                ),
                TextButton(
                  onPressed: _toggleFormMode,
                  child: Text(_isLoginForm
                      ? 'Nog geen account? Registreer nu'
                      : 'Heb je al een account? Log in'),
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

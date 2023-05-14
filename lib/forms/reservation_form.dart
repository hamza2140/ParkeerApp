import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class ReservationFormPage extends StatelessWidget {
  final LatLng parkingSpot;

  ReservationFormPage({required this.parkingSpot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ReserveringsFormulier"),
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
            const SizedBox(height: 20.0),
            const Text(
              'Tijdstip reserveren:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Tijdstip',
              ),
            ),
            const SizedBox(height: 20.0),
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

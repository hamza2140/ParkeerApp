import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/database_manager.dart';
import 'package:project/map_homepage.dart';

class ParkingLot extends StatefulWidget {
  const ParkingLot({super.key});

  @override
  State<ParkingLot> createState() => _ParkingLotState();
}

class _ParkingLotState extends State<ParkingLot> {
  final TextEditingController _addressController = TextEditingController();
  Future<Map<String, dynamic>> fetchCoordinates(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        GeoPoint gp = GeoPoint(
            double.parse(data[0]['lat']), double.parse(data[0]['lon']));
        DatabaseManager().addParking(gp);
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkeerplaats toevoegen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Voeg adres',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                fetchCoordinates(_addressController.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapWidget()),
                );
              },
              child: const Text('Voeg toe'),
            ),
          ],
        ),
      ),
    );
  }
}

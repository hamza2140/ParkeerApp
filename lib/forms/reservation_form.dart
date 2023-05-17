import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/map_homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ReservationFormPage extends StatefulWidget {
  final ParkingSpot parkingSpot;

  ReservationFormPage({required this.parkingSpot});

  @override
  _ReservationFormPageState createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  TimeOfDay _reserveTime = TimeOfDay.now();
  TimeOfDay _departureTime = TimeOfDay.now();

  Future<void> _submitReservation() async {
    try {
      // Controleer of het gereserveerde tijdstip in de toekomst ligt
      final now = DateTime.now();
      final reserveDateTime = DateTime(
          now.year, now.month, now.day, _reserveTime.hour, _reserveTime.minute);
      final departureDateTime = DateTime(now.year, now.month, now.day,
          _departureTime.hour, _departureTime.minute);

      if (reserveDateTime.isBefore(now) || departureDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Je kunt niet in het verleden reserveren. Selecteer een geldig tijdstip.'),
        ));
        return;
      }

      // Controleer of het document al bestaat
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('parkingSpots')
          .doc(widget.parkingSpot.position.toString())
          .get();

      if (documentSnapshot.exists) {
        // Update het bestaande document
        await FirebaseFirestore.instance
            .collection('parkingSpots')
            .doc(widget.parkingSpot.position.toString())
            .update({'isReserved': true});
      } else {
        // Maak een nieuw document aan
        await FirebaseFirestore.instance
            .collection('parkingSpots')
            .doc(widget.parkingSpot.position.toString())
            .set({'isReserved': true});
      }

      // Maak een nieuwe reservering aan in Firestore
      await FirebaseFirestore.instance.collection('reservations').add({
        'parkingSpotPosition': widget.parkingSpot.position.toString(),
        'reserveTime': {
          'hour': _reserveTime.hour,
          'minute': _reserveTime.minute,
        },
        'departureTime': {
          'hour': _departureTime.hour,
          'minute': _departureTime.minute,
        },
      });

      setState(() {
        widget.parkingSpot.isReserved = true;
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error creating reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error creating reservation. Please try again.'),
      ));
    }
  }

  Future<void> _showTimePicker(BuildContext context, bool isReserveTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isReserveTime) {
          _reserveTime = pickedTime;
        } else {
          _departureTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Parking Spot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Parking Spot at ${widget.parkingSpot.position}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _showTimePicker(context, true),
              child: Text(
                'Reserve Time: ${_reserveTime.format(context)}',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _showTimePicker(context, false),
              child: Text(
                'Departure Time: ${_departureTime.format(context)}',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _submitReservation,
              child: Text('Reserve Parking Spot'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getAddress(double lat, double lng) async {
  String url =
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['address']['road'] ?? '';
  } else {
    throw Exception('Failed to get address.');
  }
}

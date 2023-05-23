import 'package:flutter/material.dart';
import 'package:project/map_homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'package:project/database_manager.dart';
import 'package:project/vehicle.dart';

class ReservationFormPage extends StatefulWidget {
  final ParkingSpot parkingSpot;
  final List<String> reservedTimes;

  ReservationFormPage({
    required this.parkingSpot,
    required this.reservedTimes,
  });

  @override
  _ReservationFormPageState createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  TimeOfDay _reserveTime = TimeOfDay.now();
  TimeOfDay _departureTime = TimeOfDay.now();
  List<Vehicle> vehicles = [];
  Vehicle? selectedValue = null;

  Future<void> _submitReservation() async {
    try {
      final now = DateTime.now();
      final reserveDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _reserveTime.hour,
        _reserveTime.minute,
      );
      final departureDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _departureTime.hour,
        _departureTime.minute,
      );

      if (reserveDateTime.isBefore(now) || departureDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Je kunt niet in het verleden reserveren. Selecteer een geldig tijdstip.'),
        ));
        return;
      }

      if (reserveDateTime.isAfter(departureDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Het reserveertijdstip moet voor het vertrektijdstip liggen.'),
        ));
        return;
      }

      final overlappingReservation =
          widget.reservedTimes.firstWhereOrNull((time) {
        final match =
            RegExp(r'Reserved from ([\d-: ]+) to ([\d-: ]+)').firstMatch(time);
        if (match != null) {
          final reservedFrom = DateTime.parse(match.group(1)!);
          final reservedTo = DateTime.parse(match.group(2)!);
          return reserveDateTime.isBefore(reservedTo) &&
              departureDateTime.isAfter(reservedFrom);
        }
        return false;
      });

      if (overlappingReservation != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'De geselecteerde tijden overlappen met een bestaande reservering: $overlappingReservation'),
        ));
        return;
      }

      // Voeg de gemaakte reservering toe aan de lijst reservedTimes
      final reserveTimeString = reserveDateTime.toString();
      final departureTimeString = departureDateTime.toString();
      final newReservationTime =
          'Reserved from $reserveTimeString to $departureTimeString';
      widget.reservedTimes.add(newReservationTime);

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

      Navigator.pop(context, true);
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
            FutureBuilder<List<DocumentSnapshot>>(
              future: DatabaseManager().getDropdownData(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  print(snapshot.data?.length);
                  // Data has been successfully fetched
                  List<DocumentSnapshot> data = snapshot.data!;
                  // Extract the relevant values from the fetched data (e.g., document fields)
                  if (vehicles.isEmpty) {
                    for (var element in data) {
                      vehicles.add(Vehicle(
                          model: element.get("model"),
                          brand: element.get("brand"),
                          id: int.parse(element.id)));
                      print(element.data());
                    }
                  }
                  // Set an initial value for the dropdown (optional)
                  print(selectedValue?.brand);
                  return DropdownButton<Vehicle>(
                    value: selectedValue,
                    items: vehicles.map((Vehicle v) {
                      return DropdownMenuItem<Vehicle>(
                        value: v,
                        child: Text("${v.brand} - ${v.model}"),
                      );
                    }).toList(),
                    onChanged: (Vehicle? newValue) {
                      // Handle the selection of a dropdown item
                      setState(() {
                        print(selectedValue);
                        print(newValue);
                        selectedValue = newValue;
                      });
                    },
                  );
                }
              },
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

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/forms/parking_lot.dart';
import 'package:project/vehicles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_manager.dart';
import 'forms/login_page.dart';
import 'forms/reservation_form.dart';
import 'bottom_navbar.dart';
import 'dart:core';

class ParkingSpot {
  LatLng position;
  bool isReserved;
  List<String> reservedTimes;

  ParkingSpot({
    required this.position,
    this.isReserved = false,
    this.reservedTimes = const [],
  });
}

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  //navbar naar vehicles
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShowVehicles()),
        );
      }
    });
  }

//map zelf
  List<ParkingSpot> parkingSpots = [];

  @override
  void initState() {
    super.initState();
    fetchParkingSpots();
  }

  Future<void> fetchParkingSpots() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('parkingspots').get();
      final List<ParkingSpot> spots = [];

      for (var doc in snapshot.docs) {
        final position = LatLng(
          doc['Locatie'].latitude,
          doc['Locatie'].longitude,
        );

        final spot = ParkingSpot(position: position);

        final reservedTimes =
            await fetchReservedTimes(spot.position.toString());
        if (reservedTimes.isNotEmpty) {
          spot.isReserved = true;
          spot.reservedTimes = reservedTimes;
        }

        spots.add(spot);
      }

      setState(() {
        parkingSpots = spots;
      });
    } catch (e) {
      print('Error fetching parking spots: $e');
    }
  }

  Future<List<String>> fetchReservedTimes(String parkingSpotPosition) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('parkingSpotPosition', isEqualTo: parkingSpotPosition)
          .get();

      final reservedTimes = snapshot.docs.map((doc) {
        final reserveTime = doc['reserveTime'];
        final departureTime = doc['departureTime'];

        final reserveDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          reserveTime['hour'],
          reserveTime['minute'],
        );

        final departureDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          departureTime['hour'],
          departureTime['minute'],
        );

        return 'Reserved from ${reserveDateTime.toString()} to ${departureDateTime.toString()}';
      }).toList();

      return reservedTimes;
    } catch (e) {
      print('Error fetching reserved times: $e');
      return [];
    }
  }

  Future<void> showReservationTimesDialog(
      List<String> reservedTimes, ParkingSpot parkingSpot) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reserveertijden'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reservedTimes.isEmpty)
              const Text('Er zijn geen reserveringen voor deze parkeerplaats')
            else
              for (var time in reservedTimes) Text(time),
          ],
        ),
        actions: [
          if (!reservedTimes.isEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToReservationForm(parkingSpot);
              },
              child: const Text('Andere tijden reserveren'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToReservationForm(ParkingSpot parkingSpot) async {
    final reservedTimes =
        await fetchReservedTimes(parkingSpot.position.toString());
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationFormPage(
          parkingSpot: parkingSpot,
          reservedTimes: reservedTimes,
        ),
      ),
    );

    if (result != null && result is bool && result) {
      setState(() {
        parkingSpot.isReserved = true;
        parkingSpot.reservedTimes.add(DateTime.now().toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => {
              DatabaseManager().logout(),
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              )
            },
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.2194475, 4.4024643),
          zoom: 14,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              for (var parkingSpot in parkingSpots)
                Marker(
                  point: parkingSpot.position,
                  width: 50,
                  height: 50,
                  builder: (context) => GestureDetector(
                    onTap: () async {
                      if (parkingSpot.isReserved) {
                        final reservedTimes = await fetchReservedTimes(
                            parkingSpot.position.toString());
                        showReservationTimesDialog(reservedTimes, parkingSpot);
                      } else {
                        navigateToReservationForm(parkingSpot);
                      }
                    },
                    child: Container(
                      child: Icon(
                        Icons.local_parking,
                        color:
                            parkingSpot.isReserved ? Colors.red : Colors.green,
                        size: 50.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ParkingLot()),
          );
        },
        tooltip: 'Ga naar formulier',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/vehicles.dart';
import 'forms/reservation_form.dart';
import 'bottom_navbar.dart';
import 'database_manager.dart';
import 'forms/login_page.dart';
import 'forms/parking_lot.dart';

class ParkingSpot {
  LatLng position;
  bool isReserved;
  List<String> reservedTimes;

  LatLng getCords() {
    return LatLng(position.latitude, position.longitude);
  }

  ParkingSpot(
      {required this.position,
      this.isReserved = false,
      this.reservedTimes = const []});
}

List<ParkingSpot> parkingSpots = [
  ParkingSpot(position: LatLng(51.260197, 4.402771)),
  ParkingSpot(position: LatLng(51.280197, 4.422771)),
  ParkingSpot(position: LatLng(51.265197, 4.412771)),
  ParkingSpot(position: LatLng(51.275197, 4.402771)),
  ParkingSpot(position: LatLng(51.255197, 4.432771)),
  ParkingSpot(position: LatLng(51.290197, 4.402771)),
  ParkingSpot(position: LatLng(51.240197, 4.422771)),
];

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShowVehicles()),
        );
      }
    });
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
          center: LatLng(51.260197, 4.402771),
          zoom: 14,
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
                  point: parkingSpot.position,
                  width: 50,
                  height: 50,
                  builder: (context) => GestureDetector(
                    onTap: () {
                      if (parkingSpot.isReserved) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Parkeerplaats gereserveerd'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    'Deze parkeerplaats is al gereserveerd voor de volgende tijdstippen:'),
                                for (var time in parkingSpot.reservedTimes)
                                  Text(time),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationFormPage(
                              parkingSpot: parkingSpot,
                            ),
                          ),
                        ).then((value) {
                          // Update de parkeerplaatsgegevens nadat de reservering is voltooid
                          if (value != null && value is bool && value) {
                            parkingSpot.isReserved = true;
                            // Voeg de gereserveerde tijd toe aan de lijst van gereserveerde tijden maar da WERKTTT NIETTT
                            parkingSpot.reservedTimes
                                .add(DateTime.now().toString());
                          }
                        });
                      }
                    },
                    child: Icon(
                      Icons.local_parking,
                      color: parkingSpot.isReserved ? Colors.red : Colors.green,
                      size: 50.0,
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
        tooltip: 'Voeg parkeerplaats toe',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

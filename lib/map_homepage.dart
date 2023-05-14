import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'forms/reservation_form.dart';

List<LatLng> parkingSpots = [
  LatLng(51.260197, 4.402771),
  LatLng(51.280197, 4.422771),
  LatLng(51.265197, 4.412771),
  LatLng(51.275197, 4.402771),
  LatLng(51.255197, 4.432771),
  LatLng(51.290197, 4.402771),
  LatLng(51.240197, 4.422771),
];

class MapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
                  child: const Icon(
                    Icons.local_parking,
                    color: Colors.green,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

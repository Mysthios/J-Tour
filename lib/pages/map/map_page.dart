import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final Place place;

  const MapPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final latitude = place.latitude ?? -8.1737; // Default lat
    final longitude = place.longitude ?? 113.6995; // Default lng

    return Scaffold(
      appBar: AppBar(
        title: Text('Peta - ${place.name}'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.jtour',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

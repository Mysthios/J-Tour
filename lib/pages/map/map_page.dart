import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'navigation.dart';

class MapPage extends StatefulWidget {
  final Place place;

  const MapPage({super.key, required this.place});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? lokasiAwal;
  late LatLng lokasiTujuan;
  final MapController _mapController = MapController();
  String errorMessage = '';
  List<LatLng> routePoints = [];
  String? routeDistance;
  String? routeDuration;
  bool isLoadingRoute = false;
  List<Map<String, dynamic>> routeSteps = [];
  bool _isRouteViewMode = false;
  double _previousZoom = 14.0;
  LatLng? _previousCenter;

  @override
  void initState() {
    super.initState();
    lokasiTujuan = LatLng(
      widget.place.latitude ?? -8.1737,
      widget.place.longitude ?? 113.6995,
    );
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Layanan lokasi tidak aktif.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Izin lokasi ditolak.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'Izin lokasi ditolak permanen.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        lokasiAwal = LatLng(position.latitude, position.longitude);
        errorMessage = '';
        _previousCenter = lokasiAwal;
      });

      await _getRoute();
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  Future<void> _getRoute() async {
    if (lokasiAwal == null) return;

    setState(() {
      isLoadingRoute = true;
      routePoints.clear();
      routeSteps.clear();
    });

    try {
      final String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${lokasiAwal!.longitude},${lokasiAwal!.latitude};'
          '${lokasiTujuan.longitude},${lokasiTujuan.latitude}'
          '?geometries=geojson&overview=full&steps=true';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final geometry = route['geometry']['coordinates'] as List;
        final steps = route['legs'][0]['steps'] as List;

        final List<LatLng> points = geometry.map((coord) {
          return LatLng(coord[1].toDouble(), coord[0].toDouble());
        }).toList();

        final distance = route['distance'] / 1000;
        final duration = route['duration'] / 60;

        List<Map<String, dynamic>> parsedSteps = [];
        for (var step in steps) {
          parsedSteps.add({
            'instruction': _getIndonesianInstruction(
                step['maneuver']['type'], step['name'] ?? ''),
            'distance': step['distance'].toDouble(),
            'duration': step['duration'].toDouble(),
            'location': LatLng(
              step['maneuver']['location'][1].toDouble(),
              step['maneuver']['location'][0].toDouble(),
            ),
          });
        }

        setState(() {
          routePoints = points;
          routeSteps = parsedSteps;
          routeDistance = '${distance.toStringAsFixed(1)} km';
          routeDuration = '${duration.toStringAsFixed(0)} menit';
          isLoadingRoute = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal mendapatkan rute: ${response.statusCode}';
          isLoadingRoute = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error mendapatkan rute: $e';
        isLoadingRoute = false;
      });
    }
  }

  String _getIndonesianInstruction(String type, String roadName) {
    String instruction = '';
    switch (type) {
      case 'depart':
        instruction = 'Mulai perjalanan';
        break;
      case 'turn':
        instruction = 'Belok';
        break;
      case 'new name':
        instruction = 'Lanjutkan';
        break;
      case 'arrive':
        instruction = 'Sampai di tujuan';
        break;
      case 'merge':
        instruction = 'Bergabung';
        break;
      case 'on ramp':
        instruction = 'Masuk ke jalan tol';
        break;
      case 'off ramp':
        instruction = 'Keluar dari jalan tol';
        break;
      case 'fork':
        instruction = 'Ambil jalur';
        break;
      case 'continue':
        instruction = 'Lanjutkan';
        break;
      default:
        instruction = 'Lanjutkan';
    }

    if (roadName.isNotEmpty && roadName != 'null') {
      instruction += ' ke $roadName';
    }

    return instruction;
  }

  void _toggleRouteView() {
    setState(() {
      if (_isRouteViewMode) {
        // Kembali ke view sebelumnya
        _isRouteViewMode = false;
        if (_previousCenter != null) {
          _mapController.move(_previousCenter!, _previousZoom);
        }
      } else {
        // Simpan posisi saat ini
        _previousZoom = _mapController.camera.zoom;
        _previousCenter = _mapController.camera.center;
        _isRouteViewMode = true;

        // Zoom out untuk melihat seluruh rute
        if (routePoints.isNotEmpty) {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(routePoints),
              padding: const EdgeInsets.all(60),
            ),
          );
        }
      }
    });
  }

  void _startNavigation() {
    if (lokasiAwal != null && routeSteps.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationPage(
            startLocation: lokasiAwal!,
            destination: lokasiTujuan,
            place: widget.place,
            routePoints: routePoints,
            routeSteps: routeSteps,
            routeDistance: routeDistance,
            routeDuration: routeDuration,
          ),
        ),
      );
    }
  }

  void restartPage() {
    setState(() {
      lokasiAwal = null;
      routePoints.clear();
      routeSteps.clear();
      routeDistance = null;
      routeDuration = null;
      errorMessage = '';
      _isRouteViewMode = false;
    });
    _getCurrentLocation().then((_) {
      if (lokasiAwal != null) {
        _mapController.move(lokasiAwal!, 14);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : lokasiAwal == null
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: lokasiAwal!,
                        initialZoom: 14,
                        interactionOptions:
                            InteractionOptions(flags: InteractiveFlag.all),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.jtour',
                        ),
                        if (routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                color: const Color(0xFF4285F4),
                                strokeWidth: 6,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            if (lokasiAwal != null)
                              Marker(
                                point: lokasiAwal!,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4285F4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            Marker(
                              point: lokasiTujuan,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA4335),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.place,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

          // Top Information Panel (Black theme like Google Maps)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF202124),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.place.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: restartPage,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Route Information
                    if (routeDistance != null && routeDuration != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34A853),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.directions_car,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        routeDuration!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  routeDistance!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                if (isLoadingRoute)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _startNavigation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4285F4),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.navigation, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mulai Navigasi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (routePoints.isNotEmpty)
            FloatingActionButton(
              onPressed: _toggleRouteView,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              heroTag: 'routeViewButton',
              elevation: 4,
              child: Icon(
                _isRouteViewMode ? Icons.gps_fixed : Icons.zoom_out_map,
                size: 24,
              ),
            ),
          // const SizedBox(height: 12),
          // FloatingActionButton(
          //   onPressed: () {
          //     if (lokasiAwal != null) {
          //       _mapController.move(lokasiAwal!, 16);
          //       setState(() {
          //         _isRouteViewMode = false;
          //       });
          //     }
          //   },
          //   backgroundColor: Colors.white,
          //   foregroundColor: Colors.black87,
          //   heroTag: 'myLocationButton',
          //   elevation: 4,
          //   child: const Icon(
          //     Icons.my_location,
          //     size: 24,
          //   ),
          // ),
        ],
      ),
    );
  }
}

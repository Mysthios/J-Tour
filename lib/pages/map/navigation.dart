import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class NavigationPage extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destination;
  final Place place;
  final List<LatLng> routePoints;
  final List<Map<String, dynamic>> routeSteps;
  final String? routeDistance;
  final String? routeDuration;

  const NavigationPage({
    super.key,
    required this.startLocation,
    required this.destination,
    required this.place,
    required this.routePoints,
    required this.routeSteps,
    this.routeDistance,
    this.routeDuration,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  bool isFollowingUser = true;
  bool _isRouteViewMode = false;
  double _previousZoom = 17.0;
  LatLng? _previousCenter;

  // Navigation specific variables
  StreamSubscription<Position>? _locationSubscription;
  int currentStepIndex = 0;
  String currentInstruction = '';
  String nextInstruction = '';
  double distanceToNextTurn = 0;
  double userSpeed = 0;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    currentLocation = widget.startLocation;
    _previousCenter = currentLocation;

    // Initialize pulse animation for user location
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));
    _pulseController!.repeat(reverse: true);

    // Initialize navigation instructions
    if (widget.routeSteps.isNotEmpty) {
      currentInstruction = widget.routeSteps[0]['instruction'];
      if (widget.routeSteps.length > 1) {
        nextInstruction = widget.routeSteps[1]['instruction'];
      }
    }

    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _pulseController?.dispose();
    super.dispose();
  }

  void _startLocationTracking() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = newLocation;
        userSpeed = position.speed * 3.6; // Convert m/s to km/h
      });

      // Update navigation instructions
      _updateNavigationInstructions(newLocation);

      // Follow user location if enabled
      if (isFollowingUser && !_isRouteViewMode) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      }
    });
  }

  void _updateNavigationInstructions(LatLng currentPos) {
    if (widget.routeSteps.isEmpty ||
        currentStepIndex >= widget.routeSteps.length) {
      return;
    }

    // Calculate distance to next step
    final nextStepLocation =
        widget.routeSteps[currentStepIndex]['location'] as LatLng;
    final distance = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      nextStepLocation.latitude,
      nextStepLocation.longitude,
    );

    setState(() {
      distanceToNextTurn = distance;
    });

    // Check if we've passed the current step
    if (distance < 20 && currentStepIndex < widget.routeSteps.length - 1) {
      setState(() {
        currentStepIndex++;
        currentInstruction = widget.routeSteps[currentStepIndex]['instruction'];
        if (currentStepIndex + 1 < widget.routeSteps.length) {
          nextInstruction =
              widget.routeSteps[currentStepIndex + 1]['instruction'];
        } else {
          nextInstruction = '';
        }
      });
    }
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
        if (widget.routePoints.isNotEmpty) {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(widget.routePoints),
              padding: const EdgeInsets.all(60),
            ),
          );
        }
      }
    });
  }

  Widget _buildNavigationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF202124),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Navigation Instruction
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getInstructionIcon(currentInstruction),
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (distanceToNextTurn > 0)
                          Text(
                            distanceToNextTurn > 1000
                                ? '${(distanceToNextTurn / 1000).toStringAsFixed(1)} km'
                                : '${distanceToNextTurn.toStringAsFixed(0)} m',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          currentInstruction.isNotEmpty
                              ? currentInstruction
                              : 'Mengikuti rute...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34A853),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${userSpeed.toStringAsFixed(0)} km/h',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Next Instruction
              if (nextInstruction.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2E30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getInstructionIcon(nextInstruction),
                        size: 20,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kemudian: $nextInstruction',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Progress indicator
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2E30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ke ${widget.place.name}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      '${widget.routeDistance} • ${widget.routeDuration}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getInstructionIcon(String instruction) {
    if (instruction.contains('Belok kiri') || instruction.contains('kiri')) {
      return Icons.turn_left;
    }
    if (instruction.contains('Belok kanan') || instruction.contains('kanan')) {
      return Icons.turn_right;
    }
    if (instruction.contains('Lurus') || instruction.contains('Lanjutkan')) {
      return Icons.straight;
    }
    if (instruction.contains('Sampai') || instruction.contains('tujuan')) {
      return Icons.flag;
    }
    if (instruction.contains('Mulai')) return Icons.play_arrow;
    if (instruction.contains('tol')) return Icons.merge_type;
    if (instruction.contains('Bergabung')) return Icons.merge;
    return Icons.navigation;
  }

  Widget _buildUserLocationMarker() {
    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            Container(
              width: 40 * _pulseAnimation!.value,
              height: 40 * _pulseAnimation!.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4285F4)
                    .withOpacity(0.2 * (1 - _pulseAnimation!.value)),
              ),
            ),
            // Main marker
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4285F4),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _stopNavigation() {
    _locationSubscription?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildNavigationPanel(),
          Expanded(
            child: currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 17,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onTap: (tapPosition, point) {
                        setState(() {
                          isFollowingUser = !isFollowingUser;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.jtour',
                      ),
                      if (widget.routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: widget.routePoints,
                              color: const Color(0xFF4285F4),
                              strokeWidth: 8,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          if (currentLocation != null)
                            Marker(
                              point: currentLocation!,
                              width: 40,
                              height: 40,
                              child: _buildUserLocationMarker(),
                            ),
                          Marker(
                            point: widget.destination,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA4335),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
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
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.routePoints.isNotEmpty)
            FloatingActionButton(
              heroTag: "routeView",
              onPressed: _toggleRouteView,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 4,
              child: Icon(
                _isRouteViewMode ? Icons.gps_fixed : Icons.zoom_out_map,
                size: 24,
              ),
            ),
          // const SizedBox(height: 12),
          // FloatingActionButton(
          //   heroTag: "follow",
          //   onPressed: () {
          //     setState(() {
          //       isFollowingUser = !isFollowingUser;
          //       _isRouteViewMode = false;
          //     });
          //     if (isFollowingUser && currentLocation != null) {
          //       _mapController.move(currentLocation!, 17);
          //     }
          //   },
          //   backgroundColor:
          //       isFollowingUser ? const Color(0xFF4285F4) : Colors.white,
          //   foregroundColor: isFollowingUser ? Colors.white : Colors.black87,
          //   elevation: 4,
          //   child: Icon(
          //     isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
          //     size: 24,
          //   ),
          // ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "stop",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF202124),
                    title: const Text(
                      'Hentikan Navigasi?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Apakah Anda yakin ingin menghentikan navigasi?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF4285F4)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _stopNavigation();
                        },
                        child: const Text(
                          'Hentikan',
                          style: TextStyle(color: Color(0xFFEA4335)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            backgroundColor: const Color(0xFFEA4335),
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(
              Icons.stop,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

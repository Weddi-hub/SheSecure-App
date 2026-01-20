import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/bluetooth_service.dart';

class MapSection extends StatefulWidget {
  final LatLng? deviceLocation;

  const MapSection({super.key, this.deviceLocation});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(28.6139, 77.2090);
  bool _isLoading = true;
  double _zoomLevel = 15.0;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(MapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deviceLocation != oldWidget.deviceLocation) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add current location marker
    _markers.add(
      Marker(
        point: _currentLocation,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );

    // Add device location marker if available
    if (widget.deviceLocation != null) {
      _markers.add(
        Marker(
          point: widget.deviceLocation!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.security,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _updateMarkers();
        _mapController.move(_currentLocation, _zoomLevel);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: _zoomLevel,
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.she_secure',
                ),
                MarkerLayer(markers: _markers),
                if (bluetoothManager.deviceLocation != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: bluetoothManager.deviceLocation!,
                        color: Colors.red.withOpacity(0.3),
                        borderColor: Colors.red,
                        borderStrokeWidth: 2,
                        radius: 50,
                      ),
                    ],
                  ),
              ],
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 1).clamp(3.0, 18.0);
                        _mapController.move(_currentLocation, _zoomLevel);
                      });
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.add, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 1).clamp(3.0, 18.0);
                        _mapController.move(_currentLocation, _zoomLevel);
                      });
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.remove, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'my_loc',
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.my_location, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  if (bluetoothManager.isConnected)
                    FloatingActionButton.small(
                      heroTag: 'device_loc',
                      onPressed: () {
                        if (bluetoothManager.deviceLocation != null) {
                          _mapController.move(bluetoothManager.deviceLocation!, 16.0);
                        } else {
                          bluetoothManager.getDeviceLocationCommand();
                        }
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.security, color: Colors.red),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You: ${_currentLocation.latitude.toStringAsFixed(4)}, '
                          '${_currentLocation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    if (bluetoothManager.deviceLocation != null)
                      Text(
                        'Device: ${bluetoothManager.deviceLocation!.latitude.toStringAsFixed(4)}, '
                            '${bluetoothManager.deviceLocation!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

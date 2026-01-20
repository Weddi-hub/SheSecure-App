import 'dart:math'; // Added for math functions
import 'package:geolocator/geolocator.dart';

import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import 'geoapify_service.dart'; // Add this import

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position with error handling
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      // Check permissions
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in app settings.';
      }

      // Get current position - Updated API
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Get current location as LatLng
  Future<LatLng?> getCurrentLocation() async {
    try {
      Position? position = await getCurrentPosition();
      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }
      return null;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Try GeoApify first
      final geoapifyResult = await GeoApifyService.reverseGeocode(lat, lng);
      if (geoapifyResult != null && geoapifyResult['formatted'] != null) {
        return geoapifyResult['formatted'];
      }

      // Fallback to geocoding package
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
        if (place.postalCode != null && place.postalCode!.isNotEmpty) addressParts.add(place.postalCode!);
        if (place.country != null && place.country!.isNotEmpty) addressParts.add(place.country!);

        return addressParts.join(', ');
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Enhanced get coordinates from address using GeoApify
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // Try GeoApify first
      final geoapifyResult = await GeoApifyService.geocodeAddress(address);
      if (geoapifyResult != null) {
        return LatLng(
          geoapifyResult['latitude'],
          geoapifyResult['longitude'],
        );
      }

      // Fallback to geocoding package
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  // Get nearby safe places (police stations, hospitals, etc.)
  Future<List<Map<String, dynamic>>> getNearbySafePlaces(
      double lat,
      double lng,
      int radius,
      ) async {
    try {
      final places = await GeoApifyService.getNearbyPlaces(
        lat,
        lng,
        'healthcare,public_building,police,government',
        radius,
      );

      if (places != null) {
        return places.map<Map<String, dynamic>>((place) {
          final props = place['properties'];
          final coords = place['geometry']['coordinates'];
          return {
            'name': props['name'] ?? 'Unknown',
            'category': props['categories']?[0] ?? 'place',
            'latitude': coords[1],
            'longitude': coords[0],
            'distance': _calculateDistance(lat, lng, coords[1], coords[0]),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting nearby places: $e');
      return [];
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = sin(dLat/2) * sin(dLat/2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLng/2) * sin(dLng/2);

    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return earthRadius * c;
  }









  // Calculate distance between two points in meters
  Future<double> calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Get continuous location updates
  Stream<Position> getLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    // Use LocationSettings instead of individual parameters
    LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  // Check if location is within safe zone
  Future<bool> isWithinSafeZone(
      double currentLat,
      double currentLng,
      double safeLat,
      double safeLng,
      double radiusMeters,
      ) async {
    try {
      double distance = await calculateDistance(
        currentLat,
        currentLng,
        safeLat,
        safeLng,
      );
      return distance <= radiusMeters;
    } catch (e) {
      print('Error checking safe zone: $e');
      return false;
    }
  }

  // Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Get bearing between two points
  double getBearing(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    double startLatRad = _toRadians(startLat);
    double startLngRad = _toRadians(startLng);
    double endLatRad = _toRadians(endLat);
    double endLngRad = _toRadians(endLng);

    double y = sin(endLngRad - startLngRad) * cos(endLatRad);
    double x = cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(endLngRad - startLngRad);

    double bearing = _toDegrees(atan2(y, x));
    return (bearing + 360) % 360;
  }

  // Helper methods for bearing calculation
  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _toDegrees(double radians) {
    return radians * 180 / pi;
  }

  // Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (1000m+)';
      case LocationAccuracy.low:
        return 'Low (500m)';
      case LocationAccuracy.medium:
        return 'Medium (100m)';
      case LocationAccuracy.high:
        return 'High (10m)';
      case LocationAccuracy.best:
        return 'Best (5m)';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation (5m)';
      default:
        return 'Unknown';
    }
  }

  // Check if we have sufficient permissions
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Request necessary permissions with explanation
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Get formatted location string
  Future<String> getFormattedLocation() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return 'Location unavailable';

      String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address != null && address.isNotEmpty) {
        return address;
      }

      return '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Unable to get location';
    }
  }
}
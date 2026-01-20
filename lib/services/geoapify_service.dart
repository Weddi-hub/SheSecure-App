import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoApifyService {
  static const String _apiKey = 'dea8a92cf5c44127bd9facb4f761a3f2';
  static const String _baseUrl = 'https://api.geoapify.com/v1';

  // Geocoding: Address to coordinates
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/search?text=${Uri.encodeComponent(address)}&apiKey=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          final geometry = feature['geometry'];
          final properties = feature['properties'];

          return {
            'latitude': geometry['coordinates'][1],
            'longitude': geometry['coordinates'][0],
            'formatted': properties['formatted'],
            'address': properties,
          };
        }
      }
      return null;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  // Reverse Geocoding: Coordinates to address
  static Future<Map<String, dynamic>?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/reverse?lat=$lat&lon=$lng&apiKey=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          final properties = feature['properties'];

          return {
            'formatted': properties['formatted'],
            'address': properties,
            'full_address': _buildFullAddress(properties),
          };
        }
      }
      return null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }

  static String _buildFullAddress(Map<String, dynamic> properties) {
    List<String> parts = [];

    if (properties['street'] != null) parts.add(properties['street']);
    if (properties['city'] != null) parts.add(properties['city']);
    if (properties['state'] != null) parts.add(properties['state']);
    if (properties['country'] != null) parts.add(properties['country']);

    return parts.join(', ');
  }

  // Get routing between two points (if needed)
  static Future<Map<String, dynamic>?> getRoute(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      String mode, // 'drive', 'walk', 'bicycle'
      ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/routing?waypoints=${startLat},${startLng}|${endLat},${endLng}&mode=$mode&apiKey=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Routing error: $e');
      return null;
    }
  }

  // Get places near location
  static Future<List<dynamic>?> getNearbyPlaces(
      double lat,
      double lng,
      String categories, // e.g., 'accommodation', 'commercial', 'healthcare'
      int radius, // in meters
      ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/places?categories=$categories&filter=circle:$lng,$lat,$radius&apiKey=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['features'];
      }
      return null;
    } catch (e) {
      print('Places error: $e');
      return null;
    }
  }
}
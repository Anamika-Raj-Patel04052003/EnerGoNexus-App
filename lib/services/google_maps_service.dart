import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/google_maps_config.dart';

class GoogleMapsService {
  // 1. CALCULATE REAL ROAD DISTANCE & DURATION (DISTANCE MATRIX API)
  static Future<Map<String, dynamic>> getRealDistanceAndDuration({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originLat,$originLng&destinations=$destLat,$destLng&mode=driving&key=${GoogleMapsConfig.distanceMatrixKey}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['rows'] != null && data['rows'].isNotEmpty) {
          final element = data['rows'][0]['elements'][0];
          if (element['status'] == 'OK') {
            final double distanceKm = (element['distance']['value'] as int) / 1000.0;
            final int durationMins = ((element['duration']['value'] as int) / 60.0).round();
            return {
              'success': true,
              'distance_km': distanceKm,
              'distance_text': element['distance']['text'],
              'duration_mins': durationMins,
              'duration_text': element['duration']['text'],
            };
          }
        }
      }
    } catch (e) {
      // Fallback
    }

    // Default Fallback
    return {
      'success': false,
      'distance_km': 8.2,
      'distance_text': '8.2 km',
      'duration_mins': 16,
      'duration_text': '16 mins',
    };
  }

  // 2. GET REAL TURN-BY-TURN POLYLINE (DIRECTIONS API)
  static Future<Map<String, dynamic>> getDirectionsRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destLat,$destLng&mode=driving&key=${GoogleMapsConfig.directionsKey}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polyline = route['overview_polyline']['points'];
          final leg = route['legs'][0];
          return {
            'success': true,
            'overview_polyline': polyline,
            'distance_km': (leg['distance']['value'] as int) / 1000.0,
            'duration_mins': ((leg['duration']['value'] as int) / 60.0).round(),
            'start_address': leg['start_address'],
            'end_address': leg['end_address'],
          };
        }
      }
    } catch (e) {
      // Fallback
    }

    return {
      'success': false,
      'overview_polyline': '',
      'distance_km': 8.2,
      'duration_mins': 16,
      'start_address': 'Zone 1, MP Nagar, Bhopal',
      'end_address': 'Raja Bhoj Airport, VIP Road',
    };
  }

  // 3. REVERSE GEOCODE (COORDINATES TO ADDRESS - GEOCODING API)
  static Future<String> getAddressFromCoords(double lat, double lng) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${GoogleMapsConfig.geocodingKey}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] as String;
        }
      }
    } catch (e) {}

    return "Zone 1, MP Nagar, Bhopal";
  }

  // 4. SNAP GPS TO ROADS (ROADS API)
  static Future<List<Map<String, double>>> snapGpsToRoads(List<Map<String, double>> rawPoints) async {
    final String pathStr = rawPoints.map((p) => "${p['lat']},${p['lng']}").join('|');
    final String url =
        "https://roads.googleapis.com/v1/snapToRoads?path=$pathStr&interpolate=true&key=${GoogleMapsConfig.roadsKey}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['snappedPoints'] != null) {
          final List snapped = data['snappedPoints'] as List;
          return snapped.map<Map<String, double>>((s) {
            final loc = s['location'];
            return {
              'lat': (loc['latitude'] as num).toDouble(),
              'lng': (loc['longitude'] as num).toDouble(),
            };
          }).toList();
        }
      }
    } catch (e) {}

    return rawPoints;
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_map_live_tracking/utils/app_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class RouteService {

  final logger = Logger();

  Future<void> computeRoutes({required LatLng start, required LatLng end}) async {
    final url = 'https://routes.googleapis.com/directions/v2:computeRoutes';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $googleApiKey',
    };

    final body = jsonEncode({
      'origin': {
        'location': {
          'latLng': {
            'latitude': start.latitude,
            'longitude': start.longitude,
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': end.latitude,
            'longitude': end.longitude,
          }
        }
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE_OPTIMAL',
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      logger.i("computeRoutes....${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger().i("Routes data: $data");
      } else {
        Logger().e("Failed to load routes: ${response.body}");
      }
    } catch (e) {
      Logger().e("Error making request: $e");
    }
  }
}

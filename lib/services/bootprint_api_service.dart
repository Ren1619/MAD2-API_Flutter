import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/bootprint_models.dart';

class BootprintApiService {
  // Base URL for the API
  static const String baseUrl = 'https://api.bootprint.space';
  final http.Client _httpClient;

  BootprintApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Generic GET request with error handling
  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
        },
      );

      // Decode the response
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check for error response
      if (responseData.containsKey('error')) {
        throw Exception(responseData['error']);
      }

      // Return the data if no error
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      rethrow;
    }
  }

  // Get both image and fact for a celestial object
  Future<SpaceImageFact> getImageAndFact(CelestialObject object) async {
    final data = await _get('/all/${object.toString()}');
    return SpaceImageFact.fromJson(data);
  }

  // Get only an image for a celestial object
  Future<SpaceImage> getImage(CelestialObject object) async {
    final data = await _get('/img/${object.toString()}');
    return SpaceImage.fromJson(data);
  }

  // Get only a fact for a celestial object
  Future<SpaceFact> getFact(CelestialObject object) async {
    final data = await _get('/fact/${object.toString()}');
    return SpaceFact.fromJson(data);
  }

  // Dispose of the http client
  void dispose() {
    _httpClient.close();
  }
}
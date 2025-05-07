import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/bootprint_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BootprintApiService {
  // Base URL for the API - will be overridden by .env if available
  final String baseUrl;
  final http.Client _httpClient;

  BootprintApiService({http.Client? httpClient, String? customBaseUrl})
    : _httpClient = httpClient ?? http.Client(),
      baseUrl =
          customBaseUrl ??
          dotenv.get('API_BASE_URL', fallback: 'https://api.bootprint.space');

  // Generic GET request with improved error handling
  Future<dynamic> _get(String endpoint) async {
    if (kDebugMode) {
      print('Making API request to: $baseUrl$endpoint');
    }

    try {
      final response = await _httpClient
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout. Server might be down or network is slow.',
              );
            },
          );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print(
          'Response body: ${response.body.substring(0, min(100, response.body.length))}...',
        );
      }

      // Check if response can be decoded as JSON
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check for error response
        if (responseData.containsKey('error')) {
          throw Exception('API Error: ${responseData['error']}');
        }

        // Return the data if no error
        if (response.statusCode == 200) {
          return responseData;
        } else {
          throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
          );
        }
      } catch (e) {
        if (e is FormatException) {
          throw Exception(
            'Invalid response format: Unable to parse JSON. Response: ${response.body.substring(0, min(100, response.body.length))}...',
          );
        }
        rethrow;
      }
    } on SocketException {
      throw Exception(
        'Network error: Unable to connect to the server. Please check your internet connection.',
      );
    } on HttpException {
      throw Exception('HTTP error: Server request failed.');
    } on FormatException {
      throw Exception('Format error: Bad response format.');
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Error retrieving data: $e');
    }
  }

  // Utility function to get min value
  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Get both image and fact for a celestial object
  Future<SpaceImageFact> getImageAndFact(CelestialObject object) async {
    final data = await _get('/all/${object.toString().split('.').last}');
    return SpaceImageFact.fromJson(data);
  }

  // Get only an image for a celestial object
  Future<SpaceImage> getImage(CelestialObject object) async {
    final data = await _get('/img/${object.toString().split('.').last}');
    return SpaceImage.fromJson(data);
  }

  // Get only a fact for a celestial object
  Future<SpaceFact> getFact(CelestialObject object) async {
    final data = await _get('/fact/${object.toString().split('.').last}');
    return SpaceFact.fromJson(data);
  }

  // Dispose of the http client
  void dispose() {
    _httpClient.close();
  }
}

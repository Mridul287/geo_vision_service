import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeoApiService {
  // Replace this with your computer's local IP address
  // You can find it by running 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux)
  static const String serverIp = '10.27.22.117'; 
  static const String port = '5050';
  static const String baseUrl = 'http://$serverIp:$port';

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final String url = '$baseUrl/locate';
    
    developer.log('API Request: POST $url', name: 'GeoApiService');
    developer.log('File Path: ${imageFile.path}', name: 'GeoApiService');

    try {
      // Check file size (10MB limit)
      final int sizeInBytes = await imageFile.length();
      if (sizeInBytes > 10 * 1024 * 1024) {
        developer.log('Error: Image size exceeds 10MB', name: 'GeoApiService');
        throw Exception('Image size exceeds 10MB limit.');
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      // Send the request with a timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          developer.log('Error: Connection timed out', name: 'GeoApiService');
          throw Exception('Connection timed out. Please check if your server is running and accessible at $baseUrl');
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      
      developer.log('API Response Status: ${response.statusCode}', name: 'GeoApiService');
      developer.log('API Response Body: ${response.body}', name: 'GeoApiService');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        await _saveRecentUpload(result['location']);
        return result;
      } else {
        final errorMsg = 'Failed to upload image. Status code: ${response.statusCode}';
        developer.log('Error: $errorMsg', name: 'GeoApiService');
        throw Exception(errorMsg);
      }
    } on SocketException catch (e) {
      final errorMsg = 'Network error: Could not connect to the server at $baseUrl. Ensure your phone and laptop are on the same Wi-Fi and the IP is correct.';
      developer.log('SocketException: ${e.message}', name: 'GeoApiService');
      throw Exception(errorMsg);
    } catch (e) {
      developer.log('Unexpected Error: $e', name: 'GeoApiService');
      rethrow;
    }
  }

  Future<void> _saveRecentUpload(String location) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList('recent_uploads') ?? [];
    
    // Add to top, keep last 5
    recent.insert(0, '${DateTime.now().toIso8601String()}|$location');
    if (recent.length > 5) {
      recent = recent.sublist(0, 5);
    }
    
    await prefs.setStringList('recent_uploads', recent);
  }

  Future<List<Map<String, String>>> getRecentUploads() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recent = prefs.getStringList('recent_uploads') ?? [];
    
    return recent.map((item) {
      final parts = item.split('|');
      return {
        'time': parts[0],
        'location': parts[1],
      };
    }).toList();
  }
}

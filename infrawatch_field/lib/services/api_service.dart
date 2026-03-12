
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident.dart';

class ApiService {
  static const String baseUrl = 'http://10.27.22.117:8000'; // Note: Use your machine's local IP for physical devices

  Future<List<Incident>> fetchIncidents(String engineerId) async {
    final response = await http.get(Uri.parse('$baseUrl/incidents?engineer_id=$engineerId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Incident.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch incidents');
    }
  }

  Future<Incident> fetchIncidentDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/incidents/$id'));
    if (response.statusCode == 200) {
      return Incident.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch incident detail');
    }
  }

  Future<void> updateIncidentStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/incidents/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> submitFieldReport({
    required String incidentId,
    required String outcome,
    required String message,
    required String engineerId,
    required DateTime timestamp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/incidents/$incidentId/report'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'outcome': outcome,
        'message': message,
        'engineer_id': engineerId,
        'timestamp': timestamp.toIso8601String(),
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit report');
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';
import '../models/tracker_entry.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Future<AnalysisResult> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze text: ${response.statusCode}');
      }
    } catch (e) {
      // Return a mock result for demonstration if backend is unreachable
      // or throw error depending on how we want to handle it.
      throw Exception('Backend unreachable: $e');
    }
  }

  Future<List<TrackerEntry>> fetchTrackerEntries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TrackerEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch tracker entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Backend unreachable: $e');
    }
  }
}

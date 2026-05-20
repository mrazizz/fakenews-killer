import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';
import '../models/tracker_entry.dart';

class ApiService {
  // ── Production (Cloud Run) ──
  static const String baseUrl = 'https://fakenews-killer-api-966169006664.us-central1.run.app';

  // ── Local development (uncomment to use instead) ──
  // static String get baseUrl {
  //   if (kIsWeb) return 'http://localhost:8000';
  //   if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
  //   return 'http://localhost:8000';
  // }

  /// Original non-streaming analyze endpoint (kept for fallback).
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
      throw Exception('Backend unreachable: $e');
    }
  }

  /// SSE streaming analyze endpoint — yields one event per agent completion.
  ///
  /// Events are Maps with keys:
  ///   - "agent": "reader" | "analyst" | "strategist" | "executor" | "pipeline"
  ///   - "status": "complete" | "error"
  ///   - "result": full AnalyzeResponse JSON (only on pipeline complete)
  ///   - "error": error message string (only on error)
  Stream<Map<String, dynamic>> analyzeStream(String text) async* {
    final client = http.Client();
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/analyze/stream'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.body = jsonEncode({'text': text});

      final response = await client.send(request).timeout(
        const Duration(seconds: 120),
      );

      if (response.statusCode != 200) {
        throw Exception('SSE endpoint returned ${response.statusCode}');
      }

      // Buffer for partial lines across chunks
      String buffer = '';

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        // Keep the last element — it may be an incomplete line
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('data: ')) {
            try {
              final jsonStr = trimmed.substring(6);
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              yield data;
            } catch (_) {
              // Skip malformed JSON lines
            }
          }
        }
      }

      // Process any remaining buffer
      if (buffer.trim().startsWith('data: ')) {
        try {
          final jsonStr = buffer.trim().substring(6);
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          yield data;
        } catch (_) {}
      }
    } catch (e) {
      yield {'agent': 'pipeline', 'status': 'error', 'error': e.toString()};
    } finally {
      client.close();
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

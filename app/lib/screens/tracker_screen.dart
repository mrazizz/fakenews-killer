import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tracker_entry.dart';
import '../services/api_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TrackerEntry>> _trackerFuture;

  @override
  void initState() {
    super.initState();
    _trackerFuture = _apiService.fetchTrackerEntries();
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'TRUE':
        return const Color(0xFF2ECC71);
      case 'FALSE':
        return const Color(0xFFE74C3C);
      case 'MISLEADING':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF8A8A9A);
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFE74C3C);
      case 'MEDIUM':
        return const Color(0xFFF39C12);
      case 'LOW':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF8A8A9A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000816),
        elevation: 0,
        title: Text('Misinformation Tracker', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<TrackerEntry>>(
        future: _trackerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tracker data',
                      style: GoogleFonts.outfit(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF93C5FD)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _trackerFuture = _apiService.fetchTrackerEntries();
                        });
                      },
                      child: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No entries found.', style: TextStyle(color: Color(0xFF93C5FD))));
          }

          final entries = snapshot.data!;
          final total = entries.length;
          final falseCount = entries.where((e) => e.verdict.toUpperCase() == 'FALSE').length;
          final misleadingCount = entries.where((e) => e.verdict.toUpperCase() == 'MISLEADING').length;

          final percentFalse = total > 0 ? (falseCount / total * 100).toStringAsFixed(1) : '0';
          final percentMisleading = total > 0 ? (misleadingCount / total * 100).toStringAsFixed(1) : '0';

          return Column(
            children: [
              // Stats Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('Total', total.toString(), const Color(0xFF3B82F6))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('False', '$percentFalse%', const Color(0xFFE74C3C))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Misleading', '$percentMisleading%', const Color(0xFFF39C12))),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final verdictColor = _getVerdictColor(entry.verdict);
                    final riskColor = _getRiskColor(entry.spreadRisk);

                    return Card(
                      color: const Color(0xFF0A1628),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: verdictColor.withOpacity(0.3), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: verdictColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    entry.verdict.toUpperCase(),
                                    style: TextStyle(
                                      color: verdictColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  entry.date,
                                  style: const TextStyle(
                                    color: Color(0xFF93C5FD),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              entry.claimPreview,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  'Spread Risk:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF93C5FD),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: riskColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    entry.spreadRisk.toUpperCase(),
                                    style: TextStyle(
                                      color: riskColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      color: const Color(0xFF0A1628),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF93C5FD),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

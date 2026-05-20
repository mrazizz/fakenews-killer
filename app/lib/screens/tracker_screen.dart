import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/tracker_entry.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../widgets/app_scaffold.dart';
import 'verdict_card_screen.dart';
import 'results_screen.dart';

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
        return const Color(0xFF22C55E);
      case 'FALSE':
        return const Color(0xFFFF4444);
      case 'MISLEADING':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF4444);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      case 'LOW':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }

  void _onEntryTap(TrackerEntry entry) {
    AnalysisResult result;
    if (entry.executorData != null) {
      result = AnalysisResult.fromJson({
        'executor': entry.executorData,
        'analyst': entry.analystData,
        'created_at': entry.date,
      });
    } else {
      result = AnalysisResult(
        verdict: entry.verdict,
        confidenceScore: entry.confidenceScore,
        keyFinding: entry.claimPreview,
        claimsBreakdown: [
          ClaimBreakdown(
            claim: entry.claimPreview,
            status: entry.verdict,
            explanation: 'Retrieved from legacy tracker database. Full analysis data was not saved for this entry.',
          ),
        ],
        sourcesAnalyzed: [],
        timestamp: entry.date,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Misinformation Tracker',
      currentRoute: 'tracker',
      body: FutureBuilder<List<TrackerEntry>>(
        future: _trackerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE5E5E5)));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFFF4444), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tracker data',
                      style:
                          GoogleFonts.outfit(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF8E8E8E)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _trackerFuture = _apiService.fetchTrackerEntries();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No entries found.',
                    style: TextStyle(color: Color(0xFF8E8E8E))));
          }

          final allEntries = snapshot.data!;
          final entries = allEntries.where((e) => !e.verdict.toUpperCase().contains('UNVERIFIED')).toList();
          if (entries.isEmpty) {
            return const Center(
                child: Text('No verified entries found.',
                    style: TextStyle(color: Color(0xFF8E8E8E))));
          }
          final total = entries.length;
          final falseCount =
              entries.where((e) => e.verdict.toUpperCase() == 'FALSE').length;
          final misleadingCount = entries
              .where((e) => e.verdict.toUpperCase() == 'MISLEADING')
              .length;
          final percentFalse = total > 0
              ? (falseCount / total * 100).toStringAsFixed(1)
              : '0';
          final percentMisleading = total > 0
              ? (misleadingCount / total * 100).toStringAsFixed(1)
              : '0';

          return Column(
            children: [
              // Stats Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Total', total.toString(), const Color(0xFFE5E5E5))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildStatCard(
                            'False', '$percentFalse%', const Color(0xFFFF4444))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildStatCard('Misleading',
                            '$percentMisleading%', const Color(0xFFF59E0B))),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final verdictColor = _getVerdictColor(entry.verdict);
                    final riskColor = _getRiskColor(entry.spreadRisk);

                    return InkWell(
                      onTap: () => _onEntryTap(entry),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.white.withOpacity(0.05),
                      child: Card(
                        color: const Color(0xFF1C1C1C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color(0xFF2A2A2A), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                    _formatDate(entry.date),
                                    style: const TextStyle(
                                      color: Color(0xFF555555),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Spread Risk:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8E8E8E),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: riskColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF555555),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
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
      color: const Color(0xFF1C1C1C),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A2A)),
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
                color: const Color(0xFF8E8E8E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

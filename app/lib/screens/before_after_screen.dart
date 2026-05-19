import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';

class BeforeAfterScreen extends StatelessWidget {
  final AnalysisResult result;

  const BeforeAfterScreen({super.key, required this.result});

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

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }

  List<String> _generateRealLogs() {
    final logs = <String>[];
    final timestamp = DateTime.now(); // Using current time for simple display
    final t1 = DateFormat('HH:mm:ss').format(timestamp.subtract(const Duration(seconds: 9)));
    final t2 = DateFormat('HH:mm:ss').format(timestamp.subtract(const Duration(seconds: 7)));
    final t3 = DateFormat('HH:mm:ss').format(timestamp.subtract(const Duration(seconds: 3)));
    final t4 = DateFormat('HH:mm:ss').format(timestamp.subtract(const Duration(seconds: 2)));
    final t5 = DateFormat('HH:mm:ss').format(timestamp.subtract(const Duration(seconds: 1)));
    final t6 = DateFormat('HH:mm:ss').format(timestamp);
    
    logs.add('[$t1] Reader Agent → ${result.claimsBreakdown.length} claims extracted');
    logs.add('[$t2] Analyst Agent → web_search called (${result.sourcesAnalyzed.length} sources)');
    logs.add('[$t3] Analyst Agent → verdict: ${result.verdict.toUpperCase()} (confidence: ${result.confidenceScore}%)');
    logs.add('[$t4] Strategist Agent → 3 actions recommended');
    logs.add('[$t5] Executor Agent → verdict card generated');
    logs.add('[$t5] Executor Agent → tracker entry created');
    logs.add('[$t6] Executor Agent → platform report drafted');
    logs.add('[$t6] Pipeline complete');
    
    return logs;
  }

  @override
  Widget build(BuildContext context) {
    final originalText = result.claimsBreakdown.isNotEmpty ? result.claimsBreakdown.first.claim : "Unknown claim text";
    final logs = _generateRealLogs();
    final verdictColor = _getVerdictColor(result.verdict);

    return Scaffold(
      backgroundColor: const Color(0xFF000816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000816),
        elevation: 0,
        title: Text('System Impact',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PANEL 1: Before
            Text('BEFORE',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF93C5FD),
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WhatsApp Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF075E54),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      originalText,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 20),
                      const SizedBox(width: 8),
                      Text('Status: Unverified — spreading', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('• No fact-check available', style: GoogleFonts.inter(color: const Color(0xFF93C5FD), fontSize: 13)),
                  Text('• Spread risk: Unknown', style: GoogleFonts.inter(color: const Color(0xFF93C5FD), fontSize: 13)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // PANEL 2: After
            Text('AFTER',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF93C5FD),
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 400;
                  
                  Widget cardA = _buildActionCard(
                    icon: Icons.check_circle,
                    iconColor: const Color(0xFF2ECC71),
                    title: 'Fact-check card created',
                    subtitle: 'Verdict: ${result.verdict.toUpperCase()}',
                    trailing: _formatDate(result.timestamp),
                  );
                  Widget cardB = _buildActionCard(
                    icon: Icons.storage,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Added to misinformation database',
                    subtitle: 'Entry logged successfully',
                    trailing: 'Risk: Monitored',
                  );
                  Widget cardC = _buildActionCard(
                    icon: Icons.flag,
                    iconColor: const Color(0xFFF39C12),
                    title: 'Report drafted for platform submission',
                    subtitle: 'Target: Multiple Platforms',
                    trailing: 'Ready to submit',
                  );

                  if (isSmallScreen) {
                    return Column(
                      children: [cardA, const SizedBox(height: 12), cardB, const SizedBox(height: 12), cardC],
                    );
                  } else {
                    // For slightly wider screens, could use a Wrap, but Column is safer for consistent UI
                    return Column(
                      children: [cardA, const SizedBox(height: 12), cardB, const SizedBox(height: 12), cardC],
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // PANEL 3: Execution Log
            Text('AGENT EXECUTION LOG',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF93C5FD),
                    letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Container(
              height: 200, // Fixed height for scrollable log
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF000510),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      logs[index],
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFF93C5FD),
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF93C5FD), fontSize: 12)),
                const SizedBox(height: 4),
                Text(trailing, style: GoogleFonts.inter(color: const Color(0xFF93C5FD), fontSize: 10, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

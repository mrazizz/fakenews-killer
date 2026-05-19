import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analysis_result.dart';
import 'verdict_card_screen.dart';
import 'tracker_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultsScreen({super.key, required this.result});

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

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor(result.verdict);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Analysis Results',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ── Fixed bottom action buttons ──────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xFF0A0A0F),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1034A6)],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerdictCardScreen(result: result),
                    ),
                  ),
                  icon: const Icon(Icons.credit_card, color: Colors.white),
                  label: const Text('See Verdict Card',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TrackerScreen()),
                  ),
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: const Text('View Tracker',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Verdict Badge ────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: verdictColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: verdictColor, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: verdictColor.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    result.verdict.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: verdictColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Confidence',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Text('${result.confidenceScore}%',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: result.confidenceScore / 100,
                      backgroundColor: Colors.white12,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(verdictColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Key Finding ──────────────────────────────────────────
            Text('Key Finding',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF13131A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16,
                      offset: Offset(0, 6))
                ],
              ),
              child: Text(result.keyFinding,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 24),

            // ── Per-Claim Breakdown ──────────────────────────────────
            Text('Detailed Breakdown',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            ...result.claimsBreakdown.map((claim) {
              final claimColor = _getVerdictColor(claim.status);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13131A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: claimColor, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 16,
                        offset: Offset(0, 6))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      // Fix the white/black flash on expand
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            surface: const Color(0xFF13131A),
                          ),
                    ),
                    child: ExpansionTile(
                      backgroundColor: const Color(0xFF13131A),
                      collapsedBackgroundColor: const Color(0xFF13131A),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      leading: Icon(Icons.circle, color: claimColor, size: 14),
                      title: Text(claim.claim,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      subtitle: Text(
                        claim.status.toUpperCase(),
                        style: GoogleFonts.inter(
                            color: claimColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          color: const Color(0xFF13131A),
                          child: Text(claim.explanation,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF8A8A9A),
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

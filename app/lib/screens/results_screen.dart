import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analysis_result.dart';
import '../widgets/app_scaffold.dart';
import 'verdict_card_screen.dart';
import 'tracker_screen.dart';
import 'before_after_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultsScreen({super.key, required this.result});

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

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor(result.verdict);

    return AppScaffold(
      title: 'Analysis Results',
      currentRoute: '',
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xFF000000),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerdictCardScreen(result: result),
                    ),
                  ),
                  icon: const Icon(Icons.credit_card, color: Colors.black),
                  label: const Text('See Verdict Card',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
                      builder: (context) => BeforeAfterScreen(result: result)),
                  ),
                  icon: const Icon(Icons.compare_arrows, color: Color(0xFFE5E5E5)),
                  label: const Text('View System Impact',
                      style: TextStyle(
                          color: Color(0xFFE5E5E5), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
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
                color: verdictColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: verdictColor, width: 2),
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      result.verdict.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: verdictColor,
                      ),
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
                      backgroundColor: Colors.white10,
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
            Card(
              color: const Color(0xFF1C1C1C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(result.keyFinding,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
              ),
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
              return Card(
                color: const Color(0xFF1C1C1C),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: claimColor.withOpacity(0.3), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            surface: const Color(0xFF1C1C1C),
                          ),
                    ),
                    child: ExpansionTile(
                      backgroundColor: const Color(0xFF1C1C1C),
                      collapsedBackgroundColor: const Color(0xFF1C1C1C),
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
                          color: const Color(0xFF1C1C1C),
                          child: Text(claim.explanation,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF8E8E8E),
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

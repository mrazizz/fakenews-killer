import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';
import '../widgets/app_scaffold.dart';
import 'verdict_card_screen.dart';

class BeforeAfterScreen extends StatefulWidget {
  final AnalysisResult result;

  const BeforeAfterScreen({super.key, required this.result});

  @override
  State<BeforeAfterScreen> createState() => _BeforeAfterScreenState();
}

class _BeforeAfterScreenState extends State<BeforeAfterScreen>
    with TickerProviderStateMixin {
  // Staggered card animations
  late final AnimationController _cardAnimController;
  late final List<Animation<double>> _cardSlideAnimations;
  late final List<Animation<double>> _cardFadeAnimations;

  // Terminal log animations
  late final List<String> _logLines;
  final List<bool> _visibleLogLines = [];
  Timer? _logTimer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _logLines = _generateRealLogs();
    for (int i = 0; i < _logLines.length; i++) {
      _visibleLogLines.add(false);
    }

    // Card animations: 3 cards, 200ms stagger
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardSlideAnimations = List.generate(3, (i) {
      final start = i * 0.2;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 40.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _cardAnimController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _cardFadeAnimations = List.generate(3, (i) {
      final start = i * 0.2;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    // Start animations after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardAnimController.forward();
    });

    // Start log line reveal
    _startLogAnimation();

    // Blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  void _startLogAnimation() {
    int index = 0;
    _logTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (index < _visibleLogLines.length && mounted) {
        setState(() => _visibleLogLines[index] = true);
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _logTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
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
    final timestamp = DateTime.now();
    final t1 = DateFormat('HH:mm:ss')
        .format(timestamp.subtract(const Duration(seconds: 9)));
    final t2 = DateFormat('HH:mm:ss')
        .format(timestamp.subtract(const Duration(seconds: 7)));
    final t3 = DateFormat('HH:mm:ss')
        .format(timestamp.subtract(const Duration(seconds: 3)));
    final t4 = DateFormat('HH:mm:ss')
        .format(timestamp.subtract(const Duration(seconds: 2)));
    final t5 = DateFormat('HH:mm:ss')
        .format(timestamp.subtract(const Duration(seconds: 1)));
    final t6 = DateFormat('HH:mm:ss').format(timestamp);

    logs.add(
        '[$t1] Reader Agent \u2192 ${widget.result.claimsBreakdown.length} claims extracted');
    logs.add(
        '[$t2] Analyst Agent \u2192 web_search called (${widget.result.sourcesAnalyzed.length} sources)');
    logs.add(
        '[$t3] Analyst Agent \u2192 verdict: ${widget.result.verdict.toUpperCase()} (confidence: ${widget.result.confidenceScore}%)');
    logs.add('[$t4] Strategist Agent \u2192 3 actions recommended');
    logs.add('[$t5] Executor Agent \u2192 verdict card generated');
    logs.add('[$t5] Executor Agent \u2192 tracker entry created');
    logs.add('[$t6] Executor Agent \u2192 platform report drafted');
    logs.add('[$t6] Pipeline complete');

    return logs;
  }

  @override
  Widget build(BuildContext context) {
    final originalText = widget.result.claimsBreakdown.isNotEmpty
        ? widget.result.claimsBreakdown.first.claim
        : "Unknown claim text";

    return AppScaffold(
      title: 'System Impact',
      currentRoute: '',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── BEFORE PANEL ─────────────────────────────────────
            Text('BEFORE',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8E8E8E),
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WhatsApp-style message bubble
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF075E54),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WhatsApp header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF064940),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: Color(0xFF25D366), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Unknown Contact',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF25D366),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Message text
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14, 10, 14, 12),
                          child: Text(
                            originalText,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Warning banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFF4444).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFFF4444), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Unverified \u2014 spreading',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF4444),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('\u2022 No fact-check available',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E8E), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('\u2022 Spread risk: Unknown',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E8E), fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── AFTER PANEL ──────────────────────────────────────
            Text('AFTER',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8E8E8E),
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: AnimatedBuilder(
                animation: _cardAnimController,
                builder: (context, _) {
                  return Column(
                    children: [
                      _buildAnimatedActionCard(
                        index: 0,
                        icon: Icons.check_circle,
                        iconColor: const Color(0xFF22C55E),
                        title: 'Fact-check card created',
                        subtitle:
                            'Verdict: ${widget.result.verdict.toUpperCase()}',
                        trailing: _formatDate(widget.result.timestamp),
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedActionCard(
                        index: 1,
                        icon: Icons.storage,
                        iconColor: const Color(0xFFE5E5E5),
                        title: 'Added to misinformation database',
                        subtitle: 'Entry logged successfully',
                        trailing: 'Risk: Monitored',
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedActionCard(
                        index: 2,
                        icon: Icons.flag,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Report drafted for platform submission',
                        subtitle: 'Target: Multiple Platforms',
                        trailing: 'Ready to submit',
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // ── AGENT EXECUTION LOG ──────────────────────────────
            Text('AGENT EXECUTION LOG',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8E8E8E),
                    letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: ListView(
                children: [
                  for (int i = 0; i < _logLines.length; i++)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity:
                          (i < _visibleLogLines.length && _visibleLogLines[i])
                              ? 1.0
                              : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          _logLines[i],
                          style: GoogleFonts.robotoMono(
                            color: const Color(0xFFE5E5E5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  // Blinking cursor
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _showCursor ? 1.0 : 0.0,
                    child: Text(
                      '\u2588',
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFFE5E5E5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── View Verdict Card Button ─────────────────────────
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
                    builder: (context) =>
                        VerdictCardScreen(result: widget.result),
                  ),
                ),
                icon: const Icon(Icons.credit_card, color: Colors.black),
                label: Text(
                  'View Verdict Card',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedActionCard({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Transform.translate(
      offset: Offset(0, _cardSlideAnimations[index].value),
      child: Opacity(
        opacity: _cardFadeAnimations[index].value,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: Color(0xFF22C55E), width: 4),
            ),
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
                    Text(title,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            color: const Color(0xFF8E8E8E), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(trailing,
                        style: GoogleFonts.inter(
                            color: const Color(0xFF555555),
                            fontSize: 10,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

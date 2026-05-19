import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/analysis_result.dart';
import 'package:intl/intl.dart';

class VerdictCardScreen extends StatefulWidget {
  final AnalysisResult result;

  const VerdictCardScreen({super.key, required this.result});

  @override
  State<VerdictCardScreen> createState() => _VerdictCardScreenState();
}

class _VerdictCardScreenState extends State<VerdictCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isCapturing = false;

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

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> _shareScreenshot() async {
    setState(() => _isCapturing = true);
    try {
      // Capture the card widget as an image
      final RenderRepaintBoundary boundary = _cardKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to a temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/verdict_card.png');
      await file.writeAsBytes(pngBytes);

      // Share as image
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'FakeNews Killer Verdict: ${widget.result.verdict.toUpperCase()}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not capture card: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: const Color(0xFF13131A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor(widget.result.verdict);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Verdict Card',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _isCapturing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                  onPressed: _shareScreenshot,
                  tooltip: 'Share as Image',
                ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // ── The card wrapped in RepaintBoundary for screenshot ──
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x442563EB),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.shield,
                                          color: Colors.blue, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'FakeNews Killer',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatDate(widget.result.timestamp),
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Verdict
                        Center(
                          child: Text(
                            widget.result.verdict.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 52,
                              color: verdictColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: verdictColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: verdictColor, width: 1),
                            ),
                            child: Text(
                              'AI Fact Checked',
                              style: GoogleFonts.inter(
                                  color: verdictColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confidence Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Confidence',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54)),
                            Text('${widget.result.confidenceScore}%',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: verdictColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: widget.result.confidenceScore / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(verdictColor),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Key Finding
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.search,
                                      size: 14,
                                      color: verdictColor),
                                  const SizedBox(width: 6),
                                  Text('Key Finding',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black54)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.result.keyFinding,
                                style: GoogleFonts.inter(
                                    color: Colors.black87,
                                    height: 1.5,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sources
                        if (widget.result.sourcesAnalyzed.isNotEmpty) ...[
                          Text('Sources Analyzed:',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.black54)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children:
                                widget.result.sourcesAnalyzed.map((source) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(source,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Roman Urdu Warning
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: const Color(0xFFFFEEBA)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFF856404), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Khabar phailane se pehle tehqeeq zaroori hai. Jhuti khabar phailana jurm aur gunah dono hai.',
                                  style: GoogleFonts.inter(
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF856404),
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Footer branding
                        Center(
                          child: Text(
                            'Verified by fakenewskiller.app',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Share as Image Button (outside card) ──────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1034A6)],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _shareScreenshot,
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                  label: Text(
                    _isCapturing ? 'Capturing…' : 'Share as Image',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analysis_result.dart';
import 'results_screen.dart';

class LoadingScreen extends StatefulWidget {
  final Future<AnalysisResult> analysisFuture;

  const LoadingScreen({super.key, required this.analysisFuture});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentStep = 0;
  bool _apiFinished = false;
  bool _apiError = false;
  String _errorMessage = '';
  AnalysisResult? _result;

  final List<String> _steps = [
    "Reader Agent — Extracting claims...",
    "Analyst Agent — Checking sources...",
    "Strategist Agent — Planning response...",
    "Executor Agent — Simulating actions..."
  ];

  @override
  void initState() {
    super.initState();
    _startSequence();
    _listenToApi();
  }

  Future<void> _listenToApi() async {
    try {
      _result = await widget.analysisFuture;
      if (mounted) {
        setState(() {
          _apiFinished = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiError = true;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startSequence() async {
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _currentStep++;
      });
    }

    // Wait for API to finish if it hasn't already
    while (!_apiFinished && !_apiError) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    if (_apiFinished && _result != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(result: _result!),
        ),
      );
    } else if (_apiError && mounted) {
      // If error, just pop back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 56, height: 56, errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Colors.blue, size: 56)),
              const SizedBox(height: 24),
              Text(
                'Analyzing Claim',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our AI agents are working...',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8A8A9A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              for (int i = 0; i < _steps.length; i++)
                _buildAgentCard(i, _steps[i]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentCard(int index, String title) {
    bool isPast = index < _currentStep;
    bool isCurrent = index == _currentStep;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: (isPast || isCurrent) ? 1.0 : 0.3,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF0D1929) : const Color(0xFF13131A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPast
                ? const Color(0xFF2ECC71)
                : isCurrent
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF1E1E2E),
            width: isCurrent || isPast ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isPast)
              const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 24)
            else if (isCurrent)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF3B82F6),
                  ),
                ),
              )
            else
              const SizedBox(width: 24, height: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

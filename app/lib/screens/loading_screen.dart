import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String claimText;

  const LoadingScreen({super.key, required this.claimText});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  // 0 = waiting, 1 = active, 2 = complete
  final List<int> _stepStates = [1, 0, 0, 0];
  bool _hasError = false;

  final List<String> _agentNames = ['reader', 'analyst', 'strategist', 'executor'];
  final List<String> _steps = [
    "Reader Agent \u2014 Extracting claims...",
    "Analyst Agent \u2014 Checking sources...",
    "Strategist Agent \u2014 Planning response...",
    "Executor Agent \u2014 Simulating actions...",
  ];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startSSEStream();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startSSEStream() async {
    try {
      await for (final event in _apiService.analyzeStream(widget.claimText)) {
        if (!mounted) return;
        final agent = event['agent'] as String?;
        final status = event['status'] as String?;
        if (agent == 'pipeline') {
          if (status == 'complete' && event['result'] != null) {
            final result = AnalysisResult.fromJson(
              event['result'] as Map<String, dynamic>,
            );
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsScreen(result: result),
                ),
              );
            }
          } else if (status == 'error') {
            _showError(event['error']?.toString() ?? 'Unknown error');
          }
          return;
        }
        final agentIndex = _agentNames.indexOf(agent ?? '');
        if (agentIndex != -1 && status == 'complete') {
          setState(() {
            _stepStates[agentIndex] = 2;
            if (agentIndex + 1 < _stepStates.length) {
              _stepStates[agentIndex + 1] = 1;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  void _showError(String message) {
    setState(() {
      _hasError = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: const Color(0xFFFF4444),
        duration: const Duration(seconds: 4),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield,
                    color: Color(0xFFE5E5E5),
                    size: 56,
                  ),
                ),
              ),
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
                  color: const Color(0xFF8E8E8E),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _steps.length; i++)
                      _buildAgentCard(i, _steps[i]),
                  ],
                ),
              ),
              if (_hasError) ...[
                const SizedBox(height: 24),
                Text(
                  'An error occurred. Returning...',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFF4444),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentCard(int index, String title) {
    final state = _stepStates[index];
    final isComplete = state == 2;
    final isActive = state == 1;
    final isWaiting = state == 0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: isWaiting ? 0.3 : 1.0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isComplete
                  ? const Icon(Icons.check_circle,
                      key: ValueKey('check'),
                      color: Color(0xFF22C55E),
                      size: 20)
                  : isActive
                      ? const SizedBox(
                          key: ValueKey('spinner'),
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE5E5E5),
                            ),
                          ),
                        )
                      : const Icon(Icons.chevron_right,
                          key: ValueKey('wait'),
                          color: Colors.white24,
                          size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.robotoMono(
                  color: isComplete
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF8E8E8E),
                  fontSize: 13,
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

class TrackerEntry {
  final String id;
  final String verdict;
  final String claimPreview;
  final String spreadRisk;
  final String date;
  final int confidenceScore;
  final Map<String, dynamic>? analystData;
  final Map<String, dynamic>? executorData;

  TrackerEntry({
    required this.id,
    required this.verdict,
    required this.claimPreview,
    required this.spreadRisk,
    required this.date,
    required this.confidenceScore,
    this.analystData,
    this.executorData,
  });

  factory TrackerEntry.fromJson(Map<String, dynamic> json) {
    String claimText = json['claim_text'] ?? '';
    String preview = claimText.length > 100 ? '${claimText.substring(0, 100)}...' : claimText;
    
    return TrackerEntry(
      id: json['id']?.toString() ?? '',
      verdict: json['verdict'] ?? 'UNVERIFIED',
      claimPreview: preview,
      spreadRisk: json['spread_risk'] ?? 'UNKNOWN',
      date: json['first_detected'] ?? '',
      confidenceScore: json['confidence_score'] ?? 0,
      analystData: json['analyst_data'] as Map<String, dynamic>?,
      executorData: json['executor_data'] as Map<String, dynamic>?,
    );
  }
}

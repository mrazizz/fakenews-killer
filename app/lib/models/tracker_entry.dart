class TrackerEntry {
  final String id;
  final String verdict;
  final String claimPreview;
  final String spreadRisk;
  final String date;

  TrackerEntry({
    required this.id,
    required this.verdict,
    required this.claimPreview,
    required this.spreadRisk,
    required this.date,
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
    );
  }
}

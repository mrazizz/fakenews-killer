class ClaimBreakdown {
  final String claim;
  final String status;
  final String explanation;

  ClaimBreakdown({
    required this.claim,
    required this.status,
    required this.explanation,
  });

  factory ClaimBreakdown.fromJson(Map<String, dynamic> json) {
    return ClaimBreakdown(
      claim: json['normalized_claim'] ?? 'Unknown claim',
      status: json['verdict'] ?? 'UNVERIFIED',
      explanation: json['reasoning'] ?? 'No explanation provided.',
    );
  }
}

class PlatformReport {
  final String reportType;
  final String platform;
  final String contentDescription;
  final String harmCategory;
  final String evidenceSummary;
  final String recommendedAction;
  final String reportBody;

  PlatformReport({
    required this.reportType,
    required this.platform,
    required this.contentDescription,
    required this.harmCategory,
    required this.evidenceSummary,
    required this.recommendedAction,
    required this.reportBody,
  });

  factory PlatformReport.fromJson(Map<String, dynamic> json) {
    return PlatformReport(
      reportType: json['report_type'] ?? 'Misinformation / False News',
      platform: json['platform'] ?? 'WhatsApp',
      contentDescription: json['content_description'] ?? '',
      harmCategory: json['harm_category'] ?? '',
      evidenceSummary: json['evidence_summary'] ?? '',
      recommendedAction: json['recommended_action'] ?? '',
      reportBody: json['report_body'] ?? '',
    );
  }
}

class AnalysisResult {
  final String verdict;
  final int confidenceScore;
  final String keyFinding;
  final List<ClaimBreakdown> claimsBreakdown;
  final List<String> sourcesAnalyzed;
  final String timestamp;
  final PlatformReport? platformReport;

  AnalysisResult({
    required this.verdict,
    required this.confidenceScore,
    required this.keyFinding,
    required this.claimsBreakdown,
    required this.sourcesAnalyzed,
    required this.timestamp,
    this.platformReport,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final executor = json['executor'] as Map<String, dynamic>? ?? {};
    final verdictCard = executor['verdict_card'] as Map<String, dynamic>? ?? {};
    final analyst = json['analyst'] as Map<String, dynamic>? ?? {};
    final platformReportData = executor['platform_report'] as Map<String, dynamic>?;

    var claimsList = analyst['claims_analysis'] as List? ?? [];
    var sourcesList = verdictCard['sources'] as List? ?? [];

    return AnalysisResult(
      verdict: verdictCard['overall_verdict'] ?? 'UNVERIFIED',
      confidenceScore: verdictCard['confidence_percentage'] ?? 0,
      keyFinding: verdictCard['key_finding'] ?? 'Analysis complete, but no key finding was generated.',
      claimsBreakdown: claimsList.map((c) => ClaimBreakdown.fromJson(c)).toList(),
      sourcesAnalyzed: sourcesList.map((s) => s.toString()).toList(),
      timestamp: json['created_at'] ?? DateTime.now().toIso8601String(),
      platformReport: platformReportData != null ? PlatformReport.fromJson(platformReportData) : null,
    );
  }
}

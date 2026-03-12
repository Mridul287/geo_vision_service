
class Incident {
  final String id;
  final String assetId;
  final String assetType;
  final String location;
  final double riskScore;
  final String severity;
  final DateTime assignedAt;
  final String status;
  final List<String> shapFactors;

  Incident({
    required this.id,
    required this.assetId,
    required this.assetType,
    required this.location,
    required this.riskScore,
    required this.severity,
    required this.assignedAt,
    required this.status,
    required this.shapFactors,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      assetId: json['asset_id'],
      assetType: json['asset_type'],
      location: json['location'],
      riskScore: json['risk_score'].toDouble(),
      severity: json['severity'],
      assignedAt: DateTime.parse(json['assigned_at']),
      status: json['status'],
      shapFactors: List<String>.from(json['shap_factors']),
    );
  }
}

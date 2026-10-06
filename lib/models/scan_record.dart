class ScanRecord {
  final String scanId;
  final String timestamp;
  final String diseaseName;
  final double confidenceScore;
  final String localImagePath;

  ScanRecord({
    required this.scanId,
    required this.timestamp,
    required this.diseaseName,
    required this.confidenceScore,
    required this.localImagePath,
  });

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      scanId: map['scan_id'] as String,
      timestamp: map['timestamp'] as String,
      diseaseName: map['disease_name'] as String,
      confidenceScore: (map['confidence_score'] as num).toDouble(),
      localImagePath: map['local_image_path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scan_id': scanId,
      'timestamp': timestamp,
      'disease_name': diseaseName,
      'confidence_score': confidenceScore,
      'local_image_path': localImagePath,
    };
  }
}
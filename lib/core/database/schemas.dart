class DatabaseSchemas {
  // Table: disease_remedies
  static const String tableRemedies = 'disease_remedies';
  static const String colRemedyId = 'id';
  static const String colRemedyName = 'disease_name';
  static const String colRemedyDesc = 'scientific_description';
  static const String colRemedyChemical = 'chemical_remedies';
  static const String colRemedyOrganic = 'organic_remedies';

  static const String createTableRemedies = '''
    CREATE TABLE $tableRemedies (
      $colRemedyId TEXT PRIMARY KEY,
      $colRemedyName TEXT NOT NULL,
      $colRemedyDesc TEXT NOT NULL,
      $colRemedyChemical TEXT NOT NULL,
      $colRemedyOrganic TEXT NOT NULL
    );
  ''';

  // Table: scan_history
  static const String tableHistory = 'scan_history';
  static const String colHistoryId = 'scan_id';
  static const String colHistoryTimestamp = 'timestamp';
  static const String colHistoryDiseaseName = 'disease_name';
  static const String colHistoryConfidence = 'confidence_score';
  static const String colHistoryImagePath = 'local_image_path';

  static const String createTableHistory = '''
    CREATE TABLE $tableHistory (
      $colHistoryId TEXT PRIMARY KEY,
      $colHistoryTimestamp TEXT NOT NULL,
      $colHistoryDiseaseName TEXT NOT NULL,
      $colHistoryConfidence REAL NOT NULL,
      $colHistoryImagePath TEXT NOT NULL
    );
  ''';
}
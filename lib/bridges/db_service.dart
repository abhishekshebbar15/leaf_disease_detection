import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/database/db_helper.dart';
import '../core/database/schemas.dart';
import '../models/remedy_model.dart';
import '../models/scan_record.dart';

class DBService {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  DBService({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Look up remedy details by disease class ID (e.g. 'apple_scab')
  Future<RemedyModel?> getRemedy(String diseaseId) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseSchemas.tableRemedies,
      where: '${DatabaseSchemas.colRemedyId} = ?',
      whereArgs: [diseaseId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return RemedyModel.fromMap(results.first);
  }

  /// Save raw leaf image bytes to local app storage
  Future<String> saveImageLocally(Uint8List imageBytes) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String scansFolder = p.join(directory.path, 'scans');
    final Directory scansDir = Directory(scansFolder);

    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }

    final String fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = p.join(scansFolder, fileName);

    final File file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return filePath;
  }

  /// Resolve diagnosis and persist scan history (Contract for UI)
  Future<Map<String, dynamic>> resolveAndLogScan({
    required String diseaseId,
    required double confidenceScore,
    required Uint8List imageBytes,
  }) async {
    final String scanId = _uuid.v4();
    final String timestamp = DateTime.now().toIso8601String();

    // 1. Save image to disk
    final String imagePath = await saveImageLocally(imageBytes);

    // 2. Fetch remedies from SQLite
    final RemedyModel? remedy = await getRemedy(diseaseId);
    final String diseaseName = remedy?.diseaseName ?? 'Unknown Condition';
    final String description = remedy?.scientificDescription ?? 'No details available.';
    final List<String> chemical = remedy?.chemicalRemedies ?? [];
    final List<String> organic = remedy?.organicRemedies ?? [];

    // 3. Insert record into ScanHistory
    final Database db = await _dbHelper.database;
    await db.insert(
      DatabaseSchemas.tableHistory,
      {
        DatabaseSchemas.colHistoryId: scanId,
        DatabaseSchemas.colHistoryTimestamp: timestamp,
        DatabaseSchemas.colHistoryDiseaseName: diseaseName,
        DatabaseSchemas.colHistoryConfidence: confidenceScore,
        DatabaseSchemas.colHistoryImagePath: imagePath,
      },
    );

    // 4. Return exact Diagnosis Result schema for Vinu's UI
    return {
      'scan_id': scanId,
      'timestamp': timestamp,
      'disease_name': diseaseName,
      'confidence_score': confidenceScore,
      'description': description,
      'remedies': {
        'chemical': chemical,
        'organic': organic,
      },
      'local_image_path': imagePath,
    };
  }

  /// Fetch history records ordered by newest first
  Future<List<ScanRecord>> getRecentScans({int limit = 50}) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchemas.tableHistory,
      orderBy: '${DatabaseSchemas.colHistoryTimestamp} DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => ScanRecord.fromMap(maps[i]));
  }
}
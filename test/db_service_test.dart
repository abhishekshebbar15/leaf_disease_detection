import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_disease_app/core/database/db_helper.dart';
import 'package:leaf_disease_app/core/database/schemas.dart';
import 'package:leaf_disease_app/models/remedy_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Configure SQLite FFI for macOS test execution
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    await db.execute(DatabaseSchemas.createTableRemedies);
    await db.execute(DatabaseSchemas.createTableHistory);

    // Seed mock record directly into in-memory SQLite
    await db.insert(DatabaseSchemas.tableRemedies, {
      DatabaseSchemas.colRemedyId: 'apple_scab',
      DatabaseSchemas.colRemedyName: 'Apple Scab',
      DatabaseSchemas.colRemedyDesc: 'Fungal leaf infection',
      DatabaseSchemas.colRemedyChemical: jsonEncode(['Captan 50 WP']),
      DatabaseSchemas.colRemedyOrganic: jsonEncode(['Neem oil spray']),
    });
  });

  tearDown(() async {
    await db.close();
  });

  test('SQLite disease lookup returns expected remedy model', () async {
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseSchemas.tableRemedies,
      where: '${DatabaseSchemas.colRemedyId} = ?',
      whereArgs: ['apple_scab'],
    );

    expect(results.isNotEmpty, true);
    final remedy = RemedyModel.fromMap(results.first);
    expect(remedy.diseaseName, 'Apple Scab');
    expect(remedy.chemicalRemedies.first, 'Captan 50 WP');
    expect(remedy.organicRemedies.first, 'Neem oil spray');
  });

  test('Scan history insert and retrieval works properly', () async {
    await db.insert(DatabaseSchemas.tableHistory, {
      DatabaseSchemas.colHistoryId: 'test-scan-001',
      DatabaseSchemas.colHistoryTimestamp: DateTime.now().toIso8601String(),
      DatabaseSchemas.colHistoryDiseaseName: 'Apple Scab',
      DatabaseSchemas.colHistoryConfidence: 0.94,
      DatabaseSchemas.colHistoryImagePath: '/data/app/scans/test.jpg',
    });

    final List<Map<String, dynamic>> history = await db.query(
      DatabaseSchemas.tableHistory,
      orderBy: '${DatabaseSchemas.colHistoryTimestamp} DESC',
    );

    expect(history.length, 1);
    expect(history.first['disease_name'], 'Apple Scab');
    expect(history.first['confidence_score'], 0.94);
  });
}
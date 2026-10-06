import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'schemas.dart';

class DatabaseHelper {
  static const String _dbName = 'leaf_disease_database.db';
  static const int _dbVersion = 1;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create tables
    await db.execute(DatabaseSchemas.createTableRemedies);
    await db.execute(DatabaseSchemas.createTableHistory);

    // 2. Deterministic first-boot seeding
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/remedies_seed.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      final Batch batch = db.batch();
      for (final item in jsonList) {
        batch.insert(
          DatabaseSchemas.tableRemedies,
          {
            DatabaseSchemas.colRemedyId: item['id'],
            DatabaseSchemas.colRemedyName: item['disease_name'],
            DatabaseSchemas.colRemedyDesc: item['scientific_description'],
            DatabaseSchemas.colRemedyChemical: item['chemical_remedies'],
            DatabaseSchemas.colRemedyOrganic: item['organic_remedies'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // Graceful fallback for headless unit tests where rootBundle might differ
      // ignore: avoid_print
      print('Seeding skipped or already populated: $e');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
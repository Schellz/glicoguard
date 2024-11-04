import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'glucose.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _resetDatabase(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE glucose (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        value REAL,
        meal_type TEXT,
        meal_time TEXT,
        observations TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_name TEXT NOT NULL,
        dose TEXT NOT NULL,
        unit TEXT NOT NULL,
        observation TEXT,
        time TEXT NOT NULL
      )
    ''');
  }

  Future<void> _resetDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS glucose');
    await db.execute('DROP TABLE IF EXISTS notifications');
    await _createTables(db);
  }

  Future<void> insertGlucose(Map<String, dynamic> data) async {
    final db = await database;
    try {
      if (data['value'] is! double) {
        data['value'] = (data['value'] as int).toDouble();
      }
      await db.insert(
        'glucose',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Erro ao inserir dados de glicose: $e");
    }
  }

  Future<void> insertNotification(Map<String, dynamic> data) async {
    final db = await database;
    try {
      await db.insert(
        'notifications',
        {
          'medication_name': data['medication_name'],
          'dose': data['dose'],
          'unit': data['unit'],
          'observation': data['observation'],
          'time': data['time'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Erro ao inserir notificação: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllGlucose() async {
    final db = await database;
    try {
      return await db.query('glucose');
    } catch (e) {
      print("Erro ao buscar dados de glicose: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    try {
      return await db.query('notifications');
    } catch (e) {
      print("Erro ao buscar notificações: $e");
      return [];
    }
  }

  Future<void> deleteNotification(int id) async {
    final db = await database;
    try {
      await db.delete(
        'notifications',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Erro ao excluir notificação: $e");
    }
  }
}

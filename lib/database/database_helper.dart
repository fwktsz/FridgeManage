import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

// 条件导入
import 'database_helper_web.dart' if (dart.library.io) 'database_helper_native.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported yet');
    }

    // 使用平台特定的初始化
    await initPlatformDatabase();

    String dbPath = path.join(await getDatabasesPath(), 'fridge_manager.db');
    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_dictionary(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        defaultDays INTEGER,
        storage TEXT,
        tips TEXT,
        mainCategory TEXT,
        subCategory TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        quantity REAL,
        unit TEXT,
        purchase_date INTEGER,
        expiry_date INTEGER,
        barcode TEXT,
        tags TEXT,
        status TEXT,
        storage TEXT,
        tips TEXT,
        mainCategory TEXT,
        subCategory TEXT,
        create_time INTEGER,
        update_time INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        sort INTEGER NOT NULL,
        create_time INTEGER NOT NULL
      )
    ''');

    // 插入预设数据
    await _insertInitialData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE foods ADD COLUMN storage TEXT');
      await db.execute('ALTER TABLE foods ADD COLUMN tips TEXT');
      await db.execute('ALTER TABLE foods ADD COLUMN mainCategory TEXT');
      await db.execute('ALTER TABLE foods ADD COLUMN subCategory TEXT');
    }
  }

  Future _insertInitialData(Database db) async {
    // Implementation of _insertInitialData method
  }
} 
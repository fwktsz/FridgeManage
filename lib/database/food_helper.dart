import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food.dart';

class FoodHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'food_database.db'),
      onCreate: (db, version) async {
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
      },
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS foods');
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
        }
      },
    );
  }

  // 添加食材
  Future<int> insertFood(Food food) async {
    final db = await database;
    return await db.insert(
      'foods',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有食材
  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return List.generate(maps.length, (i) {
      return Food.fromMap(maps[i]);
    });
  }

  // 更新食材
  Future<int> updateFood(Food food) async {
    final db = await database;
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  // 删除食材
  Future<int> deleteFood(int id) async {
    final db = await database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 
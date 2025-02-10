import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_dictionary.dart';
import '../data/dictionary_data.dart';

class DictionaryHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'food_dictionary.db'),
      onCreate: (db, version) async {
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
        // 插入预设数据
        await _insertInitialData(db);
      },
      version: 1,
    );
  }

  Future<void> _insertInitialData(Database db) async {
    // 这里插入预设的食材数据
    final List<Map<String, dynamic>> initialData = [
      // 蔬菜类 - 叶菜类
      {
        'name': '生菜',
        'category': '叶菜类',
        'defaultDays': 5,
        'storage': '冷藏',
        'tips': '用厨房纸吸干水分，放入保鲜袋中保存',
        'mainCategory': '蔬菜类',
        'subCategory': '叶菜类'
      },
      // ... 更多数据
    ];

    final batch = db.batch();
    for (final data in initialData) {
      batch.insert('food_dictionary', data);
    }
    await batch.commit();
  }

  Future<List<FoodDictionaryItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food_dictionary');
    return List.generate(maps.length, (i) {
      return FoodDictionaryItem(
        name: maps[i]['name'],
        category: maps[i]['category'],
        defaultDays: maps[i]['defaultDays'],
        storage: maps[i]['storage'],
        tips: maps[i]['tips'],
      );
    });
  }

  Future<List<FoodDictionaryItem>> searchItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_dictionary',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return FoodDictionaryItem(
        name: maps[i]['name'],
        category: maps[i]['category'],
        defaultDays: maps[i]['defaultDays'],
        storage: maps[i]['storage'],
        tips: maps[i]['tips'],
      );
    });
  }

  // 添加新的食材到字典
  Future<int> insertDictionaryItem(Map<String, dynamic> item) async {
    final db = await database;
    // 检查是否已存在相同的食材名称和分类
    final List<Map<String, dynamic>> existing = await db.query(
      'food_dictionary',
      where: 'name = ? AND category = ?',
      whereArgs: [item['name'], item['category']],
    );
    
    if (existing.isEmpty) {
      return await db.insert(
        'food_dictionary',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return -1; // 表示已存在
  }

  // 删除分类及其下的所有食材
  Future<void> deleteCategory(String category) async {
    final db = await database;
    await db.delete(
      'food_dictionary',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  // 获取所有分类（包括主分类和子分类）
  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> dbCategories = await db.rawQuery('''
      SELECT DISTINCT category FROM food_dictionary
      UNION
      SELECT DISTINCT mainCategory FROM food_dictionary WHERE mainCategory IS NOT NULL
      UNION
      SELECT DISTINCT subCategory FROM food_dictionary WHERE subCategory IS NOT NULL
    ''');

    // 获取预设数据中的分类
    final presetCategories = dictionaryData.expand((food) => [
      food['category'],
      food['mainCategory'],
      food['subCategory']
    ]).where((category) => category != null).cast<String>().toSet();

    // 合并分类，明确指定类型为 Set<String>
    final Set<String> allCategories = <String>{...presetCategories};
    
    // 添加数据库中的分类
    allCategories.addAll(
      dbCategories.map((map) => map['category'] as String)
    );

    // 返回排序后的列表
    return allCategories.where((category) => category.isNotEmpty).toList()..sort();
  }

  Future<List<Map<String, dynamic>>> getFoodsByCategory(String category) async {
    // 获取数据库中的数据
    final db = await database;
    final dbFoods = await db.query(
      'food_dictionary',
      where: 'category = ? OR mainCategory = ? OR subCategory = ?',
      whereArgs: [category, category, category],
    );

    // 获取预设数据中的数据
    final presetFoods = dictionaryData.where((food) => 
      food['category'] == category || 
      food['mainCategory'] == category || 
      food['subCategory'] == category
    ).toList();

    // 合并数据，避免重复
    final Map<String, Map<String, dynamic>> mergedFoods = {};
    
    // 添加数据库中的数据
    for (var food in dbFoods) {
      mergedFoods[food['name'] as String] = food;
    }
    
    // 添加预设数据（如果数据库中没有）
    for (var food in presetFoods) {
      if (!mergedFoods.containsKey(food['name'])) {
        mergedFoods[food['name']] = food;
      }
    }

    return mergedFoods.values.toList();
  }
} 
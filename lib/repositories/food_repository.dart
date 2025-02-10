import '../database/database_helper.dart';
import '../models/food.dart';

class FoodRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertFood(Food food) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.insert('foods', food.toMap());
      print('Inserted food with id: $result');
      return result;
    } catch (e) {
      print('Error inserting food: $e');
      rethrow;
    }
  }

  Future<List<Food>> getAllFoods() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('foods');
      print('Retrieved ${maps.length} foods from database');
      return List.generate(maps.length, (i) {
        try {
          return Food.fromMap(maps[i]);
        } catch (e) {
          print('Error parsing food ${maps[i]}: $e');
          rethrow;
        }
      });
    } catch (e) {
      print('Error getting all foods: $e');
      rethrow;
    }
  }

  Future<List<Food>> getExpiringFoods() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final threeDaysLater = now.add(Duration(days: 3));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'expiry_date <= ?',
      whereArgs: [threeDaysLater.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Food.fromMap(maps[i]));
  }

  Future<int> deleteFood(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateFood(Food food) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.update(
        'foods',
        food.toMap(),
        where: 'id = ?',
        whereArgs: [food.id],
      );
      print('Updated food with id: ${food.id}');
      return result;
    } catch (e) {
      print('Error updating food: $e');
      rethrow;
    }
  }
} 
import 'package:flutter/foundation.dart';
import '../models/food.dart';
import '../repositories/food_repository.dart';
import '../database/food_helper.dart';
import '../database/dictionary_helper.dart';
import '../database/database_helper.dart';

class FoodProvider with ChangeNotifier {
  final FoodRepository _repository = FoodRepository();
  final FoodHelper _foodHelper = FoodHelper();
  final DictionaryHelper _dictionaryHelper = DictionaryHelper();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Food> _foods = [];

  List<Food> get foods => _foods;

  Future<void> loadFoods() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('foods');
      
      _foods.clear();
      _foods.addAll(maps.map((map) => Food(
        id: map['id'],
        name: map['name'],
        category: map['category'],
        quantity: map['quantity'],
        unit: map['unit'],
        purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchase_date']),
        expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiry_date']),
        barcode: map['barcode'],
        tags: map['tags']?.split(',') ?? [],
        status: map['status'],
        storage: map['storage'],
        tips: map['tips'],
        mainCategory: map['mainCategory'],
        subCategory: map['subCategory'],
      )));
      
      notifyListeners();
    } catch (e) {
      print('Error loading foods: $e');
      rethrow;
    }
  }

  Future<void> addFood(Food food) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final id = await db.insert(
        'foods',
        {
          'name': food.name,
          'category': food.category,
          'quantity': food.quantity,
          'unit': food.unit,
          'purchase_date': food.purchaseDate.millisecondsSinceEpoch,
          'expiry_date': food.expiryDate.millisecondsSinceEpoch,
          'barcode': food.barcode,
          'tags': food.tags.join(','),
          'status': food.status,
          'storage': food.storage,
          'tips': food.tips,
          'mainCategory': food.mainCategory,
          'subCategory': food.subCategory,
          'create_time': now,
          'update_time': now,
        },
      );

      food.id = id;
      _foods.add(food);
      notifyListeners();
    } catch (e) {
      print('Error adding food: $e');
      rethrow;
    }
  }

  Future<void> deleteFood(int id) async {
    try {
      // 从数据库删除
      await _foodHelper.deleteFood(id);
      
      // 从内存中移除
      _foods.removeWhere((food) => food.id == id);
      
      // 通知监听器更新UI
      notifyListeners();
    } catch (e) {
      print('Error deleting food: $e');
      rethrow;
    }
  }

  Future<void> updateFood(Food food) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'foods',
        {
          'name': food.name,
          'category': food.category,
          'quantity': food.quantity,
          'unit': food.unit,
          'purchase_date': food.purchaseDate.millisecondsSinceEpoch,
          'expiry_date': food.expiryDate.millisecondsSinceEpoch,
          'barcode': food.barcode,
          'tags': food.tags.join(','),
          'status': food.status,
          'storage': food.storage,
          'tips': food.tips,
          'mainCategory': food.mainCategory,
          'subCategory': food.subCategory,
          'update_time': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [food.id],
      );

      final index = _foods.indexWhere((f) => f.id == food.id);
      if (index != -1) {
        _foods[index] = food;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating food: $e');
      rethrow;
    }
  }

  // 添加批量删除方法
  Future<void> deleteFoodsByCategory(String category) async {
    try {
      // 获取该分类下的所有食材
      final foodsToDelete = _foods.where((food) => food.category == category);
      
      // 批量删除食材
      for (var food in foodsToDelete) {
        if (food.id != null) {
          await _foodHelper.deleteFood(food.id!);
        }
      }

      // 从内存中移除这些食材
      _foods.removeWhere((food) => food.category == category);
      
      // 通知监听器更新UI
      notifyListeners();
    } catch (e) {
      print('Error deleting foods by category: $e');
      rethrow;
    }
  }

  // 添加获取分类下食材数量的方法
  int getFoodCountByCategory(String category) {
    return _foods.where((food) => food.category == category).length;
  }

  // 添加检查分类是否可以删除的方法
  Future<bool> canDeleteCategory(String category) async {
    try {
      // 检查是否有食材使用此分类
      final foodCount = getFoodCountByCategory(category);
      if (foodCount > 0) {
        // 如果有食材使用此分类，返回true，但会在UI中显示警告
        return true;
      }
      return true;
    } catch (e) {
      print('Error checking category: $e');
      return false;
    }
  }
} 
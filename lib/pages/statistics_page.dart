import 'package:flutter/material.dart';
import '../models/food.dart';
import '../repositories/food_repository.dart';
import '../providers/food_provider.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final FoodRepository _repository = FoodRepository();
  Map<String, List<Food>> _categoryFoods = {};
  int _totalCount = 0;
  int _expiringCount = 0;
  int _expiredCount = 0;
  String? _expandedCategory;
  String? _expandedStatus;
  bool _isSelectionMode = false;
  Set<int> _selectedFoodIds = {};

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('食材统计'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => _showDeleteOptionsDialog(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: '分类统计'),
              Tab(text: '状态统计'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildOverview(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCategoryStatistics(),
                  _buildStatusStatistics(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final now = DateTime.now();
    final foods = context.read<FoodProvider>().foods;
    
    int normalCount = 0;
    int expiringCount = 0;
    int expiredCount = 0;

    for (var food in foods) {
      final daysUntilExpiry = food.expiryDate.difference(now).inDays;
      if (now.isAfter(food.expiryDate)) {
        expiredCount++;
      } else if (daysUntilExpiry <= 3) {
        expiringCount++;
      } else {
        normalCount++;
      }
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '食材概览',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总数', foods.length, Colors.blue),
                _buildStatItem('正常', normalCount, Colors.green),
                _buildStatItem('临期', expiringCount, Colors.orange),
                _buildStatItem('过期', expiredCount, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _loadFoods() async {
    final foods = context.read<FoodProvider>().foods;
    final now = DateTime.now();
    
    // 按主分类或分类进行分组
    _categoryFoods = {};
    _totalCount = foods.length;
    _expiringCount = 0;
    _expiredCount = 0;

    for (var food in foods) {
      final category = food.mainCategory ?? food.category;
      if (!_categoryFoods.containsKey(category)) {
        _categoryFoods[category] = [];
      }
      _categoryFoods[category]!.add(food);

      // 计算过期和临期食材数量
      final daysUntilExpiry = food.expiryDate.difference(now).inDays;
      if (now.isAfter(food.expiryDate)) {
        _expiredCount++;
      } else if (daysUntilExpiry <= 3) {
        _expiringCount++;
      }
    }
    setState(() {});
  }

  Widget _buildCategoryStatistics() {
    final categories = _categoryFoods.keys.toList()..sort();
    return RefreshIndicator(
      onRefresh: () async {
        _loadFoods();
      },
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final foods = _categoryFoods[category] ?? [];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category),
                  Text('${foods.length}个'),
                ],
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text('${food.quantity}${food.unit}'),
                      trailing: Text(_getFoodStatus(food)),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getFoodStatus(Food food) {
    final now = DateTime.now();
    final daysUntilExpiry = food.expiryDate.difference(now).inDays;
    if (now.isAfter(food.expiryDate)) {
      return '已过期';
    } else if (daysUntilExpiry <= 3) {
      return '临期';
    }
    return '正常';
  }

  Widget _buildStatusStatistics() {
    final statusGroups = {
      '过期': _getFoodsByStatus('过期'),
      '临期': _getFoodsByStatus('临期'),
      '正常': _getFoodsByStatus('正常'),
    };

    return RefreshIndicator(
      onRefresh: () async {
        _loadFoods();
      },
      child: ListView.builder(
        itemCount: statusGroups.length,
        itemBuilder: (context, index) {
          final status = statusGroups.keys.elementAt(index);
          final foods = statusGroups[status] ?? [];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(status),
                  Text('${foods.length}个'),
                ],
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text('${food.quantity}${food.unit}'),
                      trailing: Text(food.category),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteOptionsDialog(BuildContext context) async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择删除方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_sweep, color: Colors.red),
              title: Text('按状态删除'),
              onTap: () => Navigator.pop(context, 'status'),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.red),
              title: Text('按分类删除'),
              onTap: () => Navigator.pop(context, 'category'),
            ),
          ],
        ),
      ),
    );

    if (option == null) return;

    if (option == 'status') {
      _showDeleteByStatusDialog(context);
    } else {
      _showDeleteByCategoryDialog(context);
    }
  }

  Future<void> _showDeleteByStatusDialog(BuildContext context) async {
    final now = DateTime.now();
    final foods = context.read<FoodProvider>().foods;
    
    int normalCount = 0;
    int expiringCount = 0;
    int expiredCount = 0;

    for (var food in foods) {
      final daysUntilExpiry = food.expiryDate.difference(now).inDays;
      if (now.isAfter(food.expiryDate)) {
        expiredCount++;
      } else if (daysUntilExpiry <= 3) {
        expiringCount++;
      } else {
        normalCount++;
      }
    }

    final status = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择要删除的状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expiredCount > 0)
              ListTile(
                leading: Icon(Icons.error_outline, color: Colors.red),
                title: Text('已过期 ($expiredCount)'),
                onTap: () => Navigator.pop(context, '过期'),
              ),
            if (expiringCount > 0)
              ListTile(
                leading: Icon(Icons.warning_amber, color: Colors.orange),
                title: Text('临期 ($expiringCount)'),
                onTap: () => Navigator.pop(context, '临期'),
              ),
            if (normalCount > 0)
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('正常 ($normalCount)'),
                onTap: () => Navigator.pop(context, '正常'),
              ),
          ],
        ),
      ),
    );

    if (status != null && mounted) {
      final foodsToDelete = _getFoodsByStatus(status);
      if (foodsToDelete.isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认删除'),
            content: Text('确定要删除所有${status}状态的食材吗？(${foodsToDelete.length}个)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          try {
            for (var food in foodsToDelete) {
              await context.read<FoodProvider>().deleteFood(food.id!);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除成功')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _showDeleteByCategoryDialog(BuildContext context) async {
    final categories = _categoryFoods.keys.toList();
    
    final category = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择要删除的分类'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = _categoryFoods[category]?.length ?? 0;
              return ListTile(
                leading: Icon(Icons.category),
                title: Text('$category ($count)'),
                onTap: () => Navigator.pop(context, category),
              );
            },
          ),
        ),
      ),
    );

    if (category != null && mounted) {
      final foods = _categoryFoods[category] ?? [];
      if (foods.isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认删除'),
            content: Text('确定要删除${category}分类下的所有食材吗？(${foods.length}个)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          try {
            for (var food in foods) {
              await context.read<FoodProvider>().deleteFood(food.id!);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除成功')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: $e')),
            );
          }
        }
      }
    }
  }

  List<Food> _getFoodsByStatus(String status) {
    final now = DateTime.now();
    final allFoods = context.read<FoodProvider>().foods;
    
    return allFoods.where((food) {
      final isExpired = now.isAfter(food.expiryDate);
      final daysUntilExpiry = food.expiryDate.difference(now).inDays;
      
      switch (status) {
        case '过期':
          return isExpired;
        case '临期':
          return !isExpired && daysUntilExpiry <= 3;
        case '正常':
          return !isExpired && daysUntilExpiry > 3;
        default:
          return false;
      }
    }).toList();
  }
}

// 添加一个辅助类来存储状态数据
class StatusData {
  int count;
  final Color color;

  StatusData({
    required this.count,
    required this.color,
  });
} 
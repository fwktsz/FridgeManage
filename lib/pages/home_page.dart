import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../widgets/food_list_item.dart';
import '../data/dictionary_data.dart';  // 导入字典数据
import '../models/food.dart';  // 添加这行导入
import 'add_food_page.dart';
import '../database/dictionary_helper.dart';

class _FoodSelectionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> foods;

  const _FoodSelectionDialog({Key? key, required this.foods}) : super(key: key);

  @override
  _FoodSelectionDialogState createState() => _FoodSelectionDialogState();
}

class _FoodSelectionDialogState extends State<_FoodSelectionDialog> {
  // 使用 id 或者名称作为唯一标识符来跟踪选中状态
  Set<String> _selectedFoodNames = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('选择要添加的食材'),
      content: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // 全选/反选按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
                  label: Text(_selectAll ? '取消全选' : '全选'),
                  onPressed: () {
                    setState(() {
                      _selectAll = !_selectAll;
                      if (_selectAll) {
                        _selectedFoodNames = widget.foods.map((f) => f['name'] as String).toSet();
                      } else {
                        _selectedFoodNames.clear();
                      }
                    });
                  },
                ),
                Text('已选择: ${_selectedFoodNames.length}/${widget.foods.length}'),
              ],
            ),
            Divider(),
            // 食材列表
            Expanded(
              child: ListView.builder(
                itemCount: widget.foods.length,
                itemBuilder: (context, index) {
                  final food = widget.foods[index];
                  final isSelected = _selectedFoodNames.contains(food['name']);
                  
                  return CheckboxListTile(
                    title: Text(food['name']),
                    subtitle: Text(
                      '保质期: ${food['defaultDays']}天\n'
                      '存储: ${food['storage'] ?? '未设置'}\n'
                      '建议: ${food['tips'] ?? '暂无'}'
                    ),
                    isThreeLine: true,
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedFoodNames.add(food['name']);
                        } else {
                          _selectedFoodNames.remove(food['name']);
                        }
                        // 更新全选状态
                        _selectAll = _selectedFoodNames.length == widget.foods.length;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _selectedFoodNames.isEmpty
              ? null
              : () {
                  // 返回选中的食材数据
                  final selectedFoods = widget.foods
                      .where((food) => _selectedFoodNames.contains(food['name']))
                      .toList();
                  Navigator.pop(context, selectedFoods);
                },
          child: Text('添加(${_selectedFoodNames.length})'),
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSelectionMode = false;
  Set<int> _selectedFoodIds = {};
  bool _allSelected = false;
  late FoodProvider _foodProvider;  // 添加 FoodProvider 引用

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _foodProvider = context.read<FoodProvider>();  // 初始化 FoodProvider
  }

  @override
  void initState() {
    super.initState();
    // 加载食材列表
    Future.microtask(() => 
      _foodProvider.loadFoods()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: _isSelectionMode
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedFoodIds.clear();
                    });
                  },
                )
              : null,
            title: Text('今天吃点啥'),
            actions: [
              if (!_isSelectionMode)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'quickAdd') {
                      _showQuickAddDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'quickAdd',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                          SizedBox(width: 8),
                          Text('一键添加食材'),
                        ],
                      ),
                    ),
                  ],
                ),
              if (_isSelectionMode) ...[
                IconButton(
                  icon: Icon(Icons.select_all),
                  onPressed: () {
                    setState(() {
                      if (_selectedFoodIds.length == _foodProvider.foods.length) {
                        _selectedFoodIds.clear();
                      } else {
                        _selectedFoodIds = _foodProvider.foods
                            .map((food) => food.id!)
                            .toSet();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.flip),
                  onPressed: () {
                    setState(() {
                      final allFoodIds = _foodProvider.foods
                          .map((food) => food.id!)
                          .toSet();
                      _selectedFoodIds = allFoodIds
                          .difference(_selectedFoodIds);
                    });
                  },
                ),
                TextButton(
                  onPressed: _selectedFoodIds.isEmpty ? null : _deleteSelectedFoods,
                  child: Text(
                    '删除',
                    style: TextStyle(
                      color: _selectedFoodIds.isEmpty 
                          ? Colors.grey[400]
                          : Colors.red[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = true;
                    });
                  },
                ),
              ],
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _foodProvider.loadFoods(),
            child: _foodProvider.foods.isEmpty
                ? Center(
                    child: Text('还没有添加食材哦，点击右下角添加'),
                  )
                : ListView.builder(
                    itemCount: _foodProvider.foods.length,
                    itemBuilder: (context, index) {
                      final food = _foodProvider.foods[index];
                      return FoodListItem(
                        food: food,
                        isSelectionMode: _isSelectionMode,
                        isSelected: _selectedFoodIds.contains(food.id),
                        onSelected: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedFoodIds.add(food.id!);
                            } else {
                              _selectedFoodIds.remove(food.id!);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
            onPressed: () => _showAddFoodPage(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddFoodPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFoodPage()),
    );
    // 返回后刷新列表
    if (mounted) {
      _foodProvider.loadFoods();
    }
  }

  Future<void> _deleteSelectedFoods() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除选中的${_selectedFoodIds.length}个食材吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                '删除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        for (final id in _selectedFoodIds) {
          await _foodProvider.deleteFood(id);
        }

        setState(() {
          _isSelectionMode = false;
          _selectedFoodIds.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      print('Error deleting foods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  // 修改一键添加对话框
  Future<void> _showQuickAddDialog(BuildContext context) async {
    final dictionaryHelper = DictionaryHelper();
    final categories = await dictionaryHelper.getAllCategories();

    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择要添加的食材类别'),
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  onTap: () => Navigator.pop(context, categories[index]),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCategory != null && mounted) {
      // 获取选中分类的食材列表（包括预设数据）
      final foodsInCategory = await dictionaryHelper.getFoodsByCategory(selectedCategory);
      
      if (mounted && foodsInCategory.isNotEmpty) {
        final result = await showDialog<List<Map<String, dynamic>>>(
          context: context,
          builder: (context) => _FoodSelectionDialog(foods: foodsInCategory),
        );

        if (result != null && result.isNotEmpty && mounted) {
          try {
            // 批量添加选中的食材
            for (var foodData in result) {
              final food = Food(
                name: foodData['name'],
                category: foodData['category'],
                quantity: 1,
                unit: '个',
                purchaseDate: DateTime.now(),
                expiryDate: DateTime.now().add(Duration(days: foodData['defaultDays'] ?? 7)),
                tags: [],
                status: '正常',
                storage: foodData['storage'] ?? '未设置',
                tips: foodData['tips'] ?? '暂无存储建议',
                mainCategory: foodData['mainCategory'],
                subCategory: foodData['subCategory'],
              );
              await _foodProvider.addFood(food);
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('添加成功')),
            );
          } catch (e) {
            print('Error adding foods: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('添加失败: $e')),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('该分类下暂无食材')),
        );
      }
    }
  }

  // 修改删除方法
  Future<void> _deleteFood(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除食材'),
        content: Text('确定要删除这个食材吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 使用 FoodProvider 的方法删除食材
        await _foodProvider.deleteFood(id);
        
        // 删除成功后刷新列表
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        print('Error deleting food: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_isSelectionMode) ...[
            // 添加退出删除状态的按钮
            TextButton.icon(
              icon: Icon(Icons.close),
              label: Text('退出'),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedFoodIds.clear();
                });
              },
            ),
            TextButton.icon(
              icon: Icon(_allSelected ? Icons.check_box : Icons.check_box_outline_blank),
              label: Text(_allSelected ? '取消全选' : '全选'),
              onPressed: _toggleSelectAll,
            ),
            Text('已选择: ${_selectedFoodIds.length}'),
          ] else ...[
            Text(
              '食材列表',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (_isSelectionMode)
            TextButton.icon(
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: _selectedFoodIds.isEmpty ? null : _deleteSelected,
            ),
        ],
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedFoodIds.length == _foodProvider.foods.length) {  // 使用 _foodProvider
        _selectedFoodIds.clear();
        _allSelected = false;
      } else {
        _selectedFoodIds = _foodProvider.foods  // 使用 _foodProvider
            .map((food) => food.id!)
            .toSet();
        _allSelected = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除选中的${_selectedFoodIds.length}个食材吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                '删除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        for (final id in _selectedFoodIds) {
          await _foodProvider.deleteFood(id);
        }

        setState(() {
          _isSelectionMode = false;
          _selectedFoodIds.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      print('Error deleting foods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }
} 
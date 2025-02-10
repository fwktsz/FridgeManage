import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_dictionary.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';

class FoodDictionaryPage extends StatefulWidget {
  @override
  _FoodDictionaryPageState createState() => _FoodDictionaryPageState();
}

class _FoodDictionaryPageState extends State<FoodDictionaryPage> {
  String _searchQuery = '';
  String? _selectedCategory;
  
  // 获取所有分类
  List<String> get categories => foodDictionary
      .map((item) => item.category)
      .toSet()
      .toList()
    ..sort();

  // 根据搜索和分类过滤食材
  List<FoodDictionaryItem> get filteredItems {
    return foodDictionary.where((item) {
      final matchesSearch = item.name.contains(_searchQuery) ||
          item.category.contains(_searchQuery);
      final matchesCategory = _selectedCategory == null ||
          item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('食材字典'),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索食材...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // 分类选择
          Container(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: Text('全部'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                SizedBox(width: 8),
                ...categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          // 食材列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.category} · ${item.storage}'),
                    trailing: Text('${item.defaultDays}天'),
                    onTap: () => _showFoodDetails(context, item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFoodDetails(BuildContext context, FoodDictionaryItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('分类：${item.category}'),
            Text('建议保质期：${item.defaultDays}天'),
            Text('存储方式：${item.storage}'),
            Text('保存建议：${item.tips}'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 返回到添加页面进行编辑
                      final food = Food(
                        name: item.name,
                        category: item.category,
                        quantity: 1,
                        unit: '个',
                        purchaseDate: DateTime.now(),
                        expiryDate: DateTime.now().add(
                          Duration(days: item.defaultDays),
                        ),
                        tags: [],
                        status: '正常',
                      );
                      Navigator.pop(context, food);
                    },
                    child: Text('编辑后添加'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // 直接添加食材
                        final food = Food(
                          name: item.name,
                          category: item.category,
                          quantity: 1,
                          unit: '个',
                          purchaseDate: DateTime.now(),
                          expiryDate: DateTime.now().add(
                            Duration(days: item.defaultDays),
                          ),
                          tags: [],
                          status: '正常',
                        );
                        
                        await context.read<FoodProvider>().addFood(food);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('添加成功')),
                          );
                          Navigator.pop(context);  // 关闭底部弹窗
                          Navigator.pop(context);  // 返回上一页
                        }
                      } catch (e) {
                        print('Error adding food: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('添加失败: $e')),
                          );
                        }
                      }
                    },
                    child: Text('直接添加'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../database/dictionary_helper.dart';
import '../providers/food_provider.dart';
import 'package:provider/provider.dart';

class CategoryManagePage extends StatefulWidget {
  @override
  _CategoryManagePageState createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  final DictionaryHelper _dictionaryHelper = DictionaryHelper();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _dictionaryHelper.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分类管理'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteCategoryDialog(context, category),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加分类'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '分类名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // 添加新分类到字典
      await _dictionaryHelper.insertDictionaryItem({
        'name': '示例食材',
        'category': result,
        'defaultDays': 7,
        'storage': '未设置',
        'tips': '暂无存储建议',
      });
      _loadCategories(); // 重新加载分类列表
    }
  }

  Future<void> _showDeleteCategoryDialog(BuildContext context, String category) async {
    final foodProvider = context.read<FoodProvider>();
    final foodCount = foodProvider.getFoodCountByCategory(category);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除分类'),
        content: Text(
          foodCount > 0 
              ? '确定要删除"$category"分类吗？\n该分类下有 $foodCount 个食材，它们也会被删除。'
              : '确定要删除"$category"分类吗？',
        ),
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
        // 先删除该分类下的所有食材
        await foodProvider.deleteFoodsByCategory(category);
        
        // 再删除分类
        await _dictionaryHelper.deleteCategory(category);
        
        // 重新加载分类列表
        _loadCategories();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('分类"$category"及其食材已删除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../utils/error_handler.dart';
import '../pages/edit_food_page.dart';

class FoodDetailPage extends StatefulWidget {
  final Food food;

  const FoodDetailPage({Key? key, required this.food}) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late Food _food;

  @override
  void initState() {
    super.initState();
    _food = widget.food;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('食材详情'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editFood(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteFood(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 16),
            _buildExpiryInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('名称', _food.name),
            Divider(),
            _buildInfoRow('分类', _food.category),
            Divider(),
            _buildInfoRow('数量', '${_food.quantity}${_food.unit}'),
            Divider(),
            _buildInfoRow('购买日期', _formatDate(_food.purchaseDate)),
            Divider(),
            _buildInfoRow('过期日期', _formatDate(_food.expiryDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryInfo() {
    final now = DateTime.now();
    final daysUntilExpiry = _food.expiryDate.difference(now).inDays;
    final isExpired = now.isAfter(_food.expiryDate);
    
    final color = isExpired
        ? Colors.red
        : daysUntilExpiry <= 2
            ? Colors.orange
            : Colors.green;

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.access_time, color: color),
            SizedBox(width: 16),
            Text(
              isExpired
                  ? '已过期'
                  : '还有 ${daysUntilExpiry + 1} 天过期',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _editFood(BuildContext context) async {
    final updatedFood = await Navigator.push<Food>(
      context,
      MaterialPageRoute(
        builder: (context) => EditFoodPage(food: _food),
      ),
    );
    
    if (updatedFood != null) {
      setState(() {
        _food = updatedFood;
      });
    }
  }

  void _deleteFood(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除这个食材吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<FoodProvider>().deleteFood(_food.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除成功')),
                  );
                  Navigator.pop(context); // 关闭对话框
                  Navigator.pop(context); // 返回上一页
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                  Navigator.pop(context); // 关闭对话框
                }
              }
            },
            child: Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 
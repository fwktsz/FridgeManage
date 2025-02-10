import 'package:flutter/material.dart';
import '../models/food.dart';
import '../pages/food_detail_page.dart';

class FoodListItem extends StatelessWidget {
  final Food food;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;

  const FoodListItem({
    Key? key,
    required this.food,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: isSelectionMode 
            ? () => onSelected?.call(!isSelected)
            : () => _openFoodDetail(context),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: onSelected,
                ),
                SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${food.quantity} ${food.unit} · ${food.category}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildExpiryTag(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryTag() {
    final now = DateTime.now();
    final daysUntilExpiry = food.expiryDate.difference(now).inDays;
    final isExpired = now.isAfter(food.expiryDate);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getExpiryColor(daysUntilExpiry, isExpired),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isExpired ? '已过期' : '${daysUntilExpiry + 1}天',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getExpiryColor(int days, bool isExpired) {
    if (isExpired) return Colors.red;
    if (days <= 2) return Colors.orange;
    return Colors.green;
  }

  void _openFoodDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailPage(food: food),
      ),
    );
  }
} 
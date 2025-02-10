import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../database/dictionary_helper.dart';

class EditFoodPage extends StatefulWidget {
  final Food food;

  const EditFoodPage({Key? key, required this.food}) : super(key: key);

  @override
  _EditFoodPageState createState() => _EditFoodPageState();
}

class _EditFoodPageState extends State<EditFoodPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  late DateTime _purchaseDate;
  late DateTime _expiryDate;
  List<String> _categories = [];
  final DictionaryHelper _dictionaryHelper = DictionaryHelper();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food.name);
    _categoryController = TextEditingController(text: widget.food.category);
    _quantityController = TextEditingController(text: widget.food.quantity.toString());
    _selectedUnit = widget.food.unit;
    _purchaseDate = widget.food.purchaseDate;
    _expiryDate = widget.food.expiryDate;
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
        title: Text('编辑食材'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveFood,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '食材名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? '请输入食材名称' : null,
              ),
              SizedBox(height: 16),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: widget.food.category),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _categories;
                  }
                  return _categories.where((category) =>
                      category.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String value) {
                  _categoryController.text = value;
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  _categoryController = controller;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: '分类',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                        },
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? '请输入或选择分类' : null,
                  );
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '数量',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '请输入数量';
                        }
                        if (double.tryParse(value!) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: '单位',
                        border: OutlineInputBorder(),
                      ),
                      items: ['个', '克', '千克', '包', '瓶', '盒'].map((String unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedUnit = value ?? '个';
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('购买日期'),
                subtitle: Text(_formatDate(_purchaseDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text('过期日期'),
                subtitle: Text(_formatDate(_expiryDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveFood,
                child: Text('保存'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate ? _purchaseDate : _expiryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final food = Food(
        id: widget.food.id,
        name: _nameController.text,
        category: _categoryController.text,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        tags: widget.food.tags,
        status: widget.food.status,
      );

      await context.read<FoodProvider>().updateFood(food);

      if (!_categories.contains(_categoryController.text)) {
        await _dictionaryHelper.insertDictionaryItem({
          'name': _nameController.text,
          'category': _categoryController.text,
          'defaultDays': _expiryDate.difference(_purchaseDate).inDays,
          'storage': '未设置',
          'tips': '暂无存储建议',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
} 
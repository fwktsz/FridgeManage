import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../database/dictionary_helper.dart';

class AddFoodPage extends StatefulWidget {
  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedUnit = '个';
  DateTime _purchaseDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(Duration(days: 7));
  List<String> _categories = [];
  final DictionaryHelper _dictionaryHelper = DictionaryHelper();

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
        title: Text('添加食材'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book),
            tooltip: '从食材字典选择',
            onPressed: () => _showFoodDictionaryDialog(context),
          ),
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
                          _categoryController.clear();
                        },
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? '请输入或选择分类' : null,
                    onChanged: (value) {
                      _categoryController.text = value;
                    },
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
                        if (value?.isEmpty ?? true) return '请输入数量';
                        if (double.tryParse(value!) == null) return '请输入有效的数字';
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final food = Food(
        name: _nameController.text,
        category: _categoryController.text,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        tags: [],
        status: '正常',
      );

      await context.read<FoodProvider>().addFood(food);

      // 如果是新分类，添加到字典
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
          SnackBar(content: Text('添加成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加失败: $e')),
      );
    }
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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // 添加从字典选择食材的方法
  Future<void> _showFoodDictionaryDialog(BuildContext context) async {
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择分类'),
        content: Container(
          width: double.maxFinite,
          child: FutureBuilder<List<String>>(
            future: _dictionaryHelper.getAllCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(categories[index]),
                    onTap: () => Navigator.pop(context, categories[index]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    if (selectedCategory != null) {
      // 显示该分类下的食材列表
      final selectedFood = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('选择食材'),
          content: Container(
            width: double.maxFinite,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dictionaryHelper.getFoodsByCategory(selectedCategory),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final foods = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return ListTile(
                      title: Text(food['name'] as String),
                      subtitle: Text('保质期: ${food['defaultDays']}天'),
                      onTap: () => Navigator.pop(context, food),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      if (selectedFood != null) {
        setState(() {
          _nameController.text = selectedFood['name'] as String;
          _categoryController.text = selectedFood['category'] as String;
          _expiryDate = DateTime.now().add(
            Duration(days: selectedFood['defaultDays'] as int),
          );
        });
      }
    }
  }
} 
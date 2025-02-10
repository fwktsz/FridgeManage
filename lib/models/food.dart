class Food {
  int? id;
  String name;
  String category;
  double quantity;
  String unit;
  DateTime purchaseDate;
  DateTime expiryDate;
  String? barcode;
  List<String> tags;
  String status;
  String? storage;
  String? tips;
  String? mainCategory;
  String? subCategory;

  Food({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    this.barcode,
    required this.tags,
    required this.status,
    this.storage,
    this.tips,
    this.mainCategory,
    this.subCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate.millisecondsSinceEpoch,
      'expiry_date': expiryDate.millisecondsSinceEpoch,
      'barcode': barcode,
      'tags': tags.join(','),
      'status': status,
      'storage': storage,
      'tips': tips,
      'mainCategory': mainCategory,
      'subCategory': subCategory,
      'create_time': DateTime.now().millisecondsSinceEpoch,
      'update_time': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchase_date'] as int),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiry_date'] as int),
      barcode: map['barcode'] as String?,
      tags: (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList(),
      status: map['status'] as String,
      storage: map['storage'] as String?,
      tips: map['tips'] as String?,
      mainCategory: map['mainCategory'] as String?,
      subCategory: map['subCategory'] as String?,
    );
  }

  Food copyWith({
    int? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? barcode,
    List<String>? tags,
    String? status,
    String? storage,
    String? tips,
    String? mainCategory,
    String? subCategory,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      barcode: barcode ?? this.barcode,
      tags: tags ?? List.from(this.tags),
      status: status ?? this.status,
      storage: storage ?? this.storage,
      tips: tips ?? this.tips,
      mainCategory: mainCategory ?? this.mainCategory,
      subCategory: subCategory ?? this.subCategory,
    );
  }
} 
class Category {
  final int? id;
  final String name;
  final String? icon;
  final int sort;
  final DateTime createTime;

  Category({
    this.id,
    required this.name,
    this.icon,
    required this.sort,
    required this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'sort': sort,
      'create_time': createTime.millisecondsSinceEpoch,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      sort: map['sort'],
      createTime: DateTime.fromMillisecondsSinceEpoch(map['create_time']),
    );
  }
} 
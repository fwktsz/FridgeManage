class FoodDictionaryItem {
  final String name;          // 食材名称
  final String category;      // 分类
  final int defaultDays;      // 建议保质期（天）
  final String storage;       // 存储方式
  final String tips;         // 存储建议

  FoodDictionaryItem({
    required this.name,
    required this.category,
    required this.defaultDays,
    required this.storage,
    required this.tips,
  });
}

// 预设的食材数据
final List<FoodDictionaryItem> foodDictionary = [
  // 叶菜类
  FoodDictionaryItem(
    name: '生菜',
    category: '叶菜类',
    defaultDays: 5,
    storage: '冷藏',
    tips: '用厨房纸吸干水分，放入保鲜袋中保存',
  ),
  FoodDictionaryItem(
    name: '菠菜',
    category: '叶菜类',
    defaultDays: 3,
    storage: '冷藏',
    tips: '清洗后沥干水分，用保鲜袋密封保存',
  ),
  FoodDictionaryItem(
    name: '韭菜',
    category: '叶菜类',
    defaultDays: 4,
    storage: '冷藏',
    tips: '用报纸包裹，放入保鲜袋中保存',
  ),

  // 根茎类
  FoodDictionaryItem(
    name: '胡萝卜',
    category: '根茎类',
    defaultDays: 14,
    storage: '冷藏',
    tips: '去除叶子，用保鲜袋包裹存放',
  ),
  FoodDictionaryItem(
    name: '土豆',
    category: '根茎类',
    defaultDays: 30,
    storage: '常温',
    tips: '避光、通风处存放，不要与洋葱放在一起',
  ),
  FoodDictionaryItem(
    name: '山药',
    category: '根茎类',
    defaultDays: 14,
    storage: '冷藏',
    tips: '避免与其他蔬菜接触，单独包装保存',
  ),

  // 瓜果类
  FoodDictionaryItem(
    name: '黄瓜',
    category: '瓜果类',
    defaultDays: 7,
    storage: '冷藏',
    tips: '不要与番茄等会产生乙烯的水果放在一起',
  ),
  FoodDictionaryItem(
    name: '西红柿',
    category: '瓜果类',
    defaultDays: 7,
    storage: '冷藏',
    tips: '常温下催熟后再冷藏，可延长保质期',
  ),

  // 肉类
  FoodDictionaryItem(
    name: '猪肉',
    category: '肉类',
    defaultDays: 3,
    storage: '冷藏',
    tips: '生熟分开，密封保存，最好放在冷藏室下层',
  ),
  FoodDictionaryItem(
    name: '牛肉',
    category: '肉类',
    defaultDays: 3,
    storage: '冷藏',
    tips: '避免与其他食材交叉污染，可切块分装',
  ),
  FoodDictionaryItem(
    name: '鸡肉',
    category: '肉类',
    defaultDays: 2,
    storage: '冷藏',
    tips: '生鸡肉要及时处理，避免细菌滋生',
  ),

  // 水产类
  FoodDictionaryItem(
    name: '鱼',
    category: '水产类',
    defaultDays: 2,
    storage: '冷藏',
    tips: '最好当天食用，可以用保鲜膜严密包裹',
  ),
  FoodDictionaryItem(
    name: '虾',
    category: '水产类',
    defaultDays: 2,
    storage: '冷藏',
    tips: '最好保存在0-4度的温度下，避免反复冷冻',
  ),

  // 豆制品
  FoodDictionaryItem(
    name: '豆腐',
    category: '豆制品',
    defaultDays: 3,
    storage: '冷藏',
    tips: '用清水浸泡，每天换水可延长保质期',
  ),
  FoodDictionaryItem(
    name: '腐竹',
    category: '豆制品',
    defaultDays: 180,
    storage: '常温',
    tips: '密封、防潮保存，开封后尽快食用',
  ),

  // 蛋类
  FoodDictionaryItem(
    name: '鸡蛋',
    category: '蛋类',
    defaultDays: 30,
    storage: '冷藏',
    tips: '尖端朝下存放，避免与异味食材放在一起',
  ),

  // 水果类
  FoodDictionaryItem(
    name: '苹果',
    category: '水果类',
    defaultDays: 14,
    storage: '冷藏',
    tips: '避免与其他水果放在一起，会加速其他水果成熟',
  ),
  FoodDictionaryItem(
    name: '香蕉',
    category: '水果类',
    defaultDays: 7,
    storage: '常温',
    tips: '避免与其他水果放在一起，独立保存',
  ),
  FoodDictionaryItem(
    name: '橙子',
    category: '水果类',
    defaultDays: 14,
    storage: '冷藏',
    tips: '可以用保鲜袋单独包装，避免串味',
  ),
]; 
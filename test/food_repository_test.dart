void main() {
  group('FoodRepository Tests', () {
    late FoodRepository repository;

    setUp(() {
      repository = FoodRepository();
    });

    test('insert food test', () async {
      final food = Food(/* ... */);
      final id = await repository.insertFood(food);
      expect(id, isNotNull);
    });
  });
} 
class Food {
  final int foodID;
  final int fridgeCategoryID;
  final String foodsName;
  final int defaultFoodID;
  final int preferredFoodID;
  final DateTime createdDate;
  final DateTime expirationDate;
  final DateTime consumptionDate;

  Food({
    required this.foodID,
    required this.fridgeCategoryID,
    required this.foodsName,
    required this.defaultFoodID,
    required this.preferredFoodID,
    required this.createdDate,
    required this.expirationDate,
    required this.consumptionDate,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      foodID: json['FoodID'],
      fridgeCategoryID: json['FridgeCategoryID'],
      foodsName: json['FoodsName'],
      defaultFoodID: json['DefaultFoodID'],
      preferredFoodID: json['PreferredFoodID'],
      createdDate: DateTime.parse(json['CreatedDate']),
      expirationDate: DateTime.parse(json['ExpirationDate']),
      consumptionDate: DateTime.parse(json['ConsumptionDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FoodID': foodID,
      'FridgeCategoryID': fridgeCategoryID,
      'FoodsName': foodsName,
      'DefaultFoodID': defaultFoodID,
      'PreferredFoodID': preferredFoodID,
      'CreatedDate': createdDate.toIso8601String(),
      'ExpirationDate': expirationDate.toIso8601String(),
      'ConsumptionDate': consumptionDate.toIso8601String(),
    };
  }
}
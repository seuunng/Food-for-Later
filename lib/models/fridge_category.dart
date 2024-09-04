class FridgeCategory {
  final int fridgeCategoryID;
  final int fridgeID;
  final String categoryName;

  FridgeCategory({
    required this.fridgeCategoryID,
    required this.fridgeID,
    required this.categoryName,
  });

  factory FridgeCategory.fromJson(Map<String, dynamic> json) {
    return FridgeCategory(
      fridgeCategoryID: json['FridgeCategoryID'],
      fridgeID: json['FridgeID'],
      categoryName: json['CategoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FridgeCategoryID': fridgeCategoryID,
      'FridgeID': fridgeID,
      'CategoryName': categoryName,
    };
  }
}

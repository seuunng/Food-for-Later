class ShoppingCategory {
  final int shoppingCategoryID;
  final String categoryName;

  ShoppingCategory({
    required this.shoppingCategoryID,
    required this.categoryName,
  });

  factory ShoppingCategory.fromJson(Map<String, dynamic> json) {
    return ShoppingCategory(
      shoppingCategoryID: json['ShoppingCategoryID'],
      categoryName: json['CategoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ShoppingCategoryID': shoppingCategoryID,
      'CategoryName': categoryName,
    };
  }
}


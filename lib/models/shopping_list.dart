class ShoppingList {
  final int shoppingListID;
  final int userID;
  final int shoppingCategoryID;
  final String item;

  ShoppingList({
    required this.shoppingListID,
    required this.userID,
    required this.shoppingCategoryID,
    required this.item,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      shoppingListID: json['ShoppingListID'],
      userID: json['UserID'],
      shoppingCategoryID: json['ShoppingCategoryID'],
      item: json['Item'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ShoppingListID': shoppingListID,
      'UserID': userID,
      'ShoppingCategoryID': shoppingCategoryID,
      'Item': item,
    };
  }
}
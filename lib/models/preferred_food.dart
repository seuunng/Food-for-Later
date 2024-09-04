class PreferredFood {
  final int preferredFoodID;
  final int userID;
  final String categoryName;

  PreferredFood({
    required this.preferredFoodID,
    required this.userID,
    required this.categoryName,
  });

  factory PreferredFood.fromJson(Map<String, dynamic> json) {
    return PreferredFood(
      preferredFoodID: json['PreferredFoodID'],
      userID: json['UserID'],
      categoryName: json['CategoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PreferredFoodID': preferredFoodID,
      'UserID': userID,
      'CategoryName': categoryName,
    };
  }
}

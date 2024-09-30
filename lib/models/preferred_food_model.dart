class PreferredFoodModel {
  final int preferredFoodID;
  final int userID;
  final String categoryName;

  PreferredFoodModel({
    required this.preferredFoodID,
    required this.userID,
    required this.categoryName,
  });

  factory PreferredFoodModel.fromJson(Map<String, dynamic> json) {
    return PreferredFoodModel(
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

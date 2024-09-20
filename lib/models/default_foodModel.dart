class DefaultFoodModel {
  final int defaultFoodID;
  final int userID;
  final String categoryName;

  DefaultFoodModel({
    required this.defaultFoodID,
    required this.userID,
    required this.categoryName,
  });

  factory DefaultFoodModel.fromJson(Map<String, dynamic> json) {
    return DefaultFoodModel(
      defaultFoodID: json['DefaultFoodID'],
      userID: json['UserID'],
      categoryName: json['CategoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DefaultFoodID': defaultFoodID,
      'UserID': userID,
      'CategoryName': categoryName,
    };
  }
}

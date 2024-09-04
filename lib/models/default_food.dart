class DefaultFood {
  final int defaultFoodID;
  final int userID;
  final String categoryName;

  DefaultFood({
    required this.defaultFoodID,
    required this.userID,
    required this.categoryName,
  });

  factory DefaultFood.fromJson(Map<String, dynamic> json) {
    return DefaultFood(
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

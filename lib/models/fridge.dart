class Fridge {
  final int fridgeID;
  final int userID;
  final String fridgeName;

  Fridge({
    required this.fridgeID,
    required this.userID,
    required this.fridgeName,
  });

  factory Fridge.fromJson(Map<String, dynamic> json) {
    return Fridge(
      fridgeID: json['FridgeID'],
      userID: json['UserID'],
      fridgeName: json['FridgeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FridgeID': fridgeID,
      'UserID': userID,
      'FridgeName': fridgeName,
    };
  }
}

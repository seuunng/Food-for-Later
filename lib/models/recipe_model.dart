class RecipeModel {
  final String id;
  final String userID;
  final String difficulty;
  final int serving;
  final int time;
  final List<String> foods;
  final List<String> themes;
  final List<String> methods;
  final String recipeName;
  final List<Map<String, String>> steps;
  final int views;

  RecipeModel({
    required this.id,
    required this.userID,
    required this.difficulty,
    required this.serving,
    required this.time,
    required this.foods,
    required this.themes,
    required this.methods,
    required this.recipeName,
    required this.steps,
    this.views = 0,
  });
  factory RecipeModel.fromFirestore(Map<String, dynamic> data) {
    return RecipeModel(
      id: data['id'],
      userID: data['userID'],
      recipeName: data['recipeName'],
      foods: List<String>.from(data['foods']),
      themes: List<String>.from(data['themes']),
      methods: List<String>.from(data['methods']),
      serving: data['serving'],
      difficulty: data['difficulty'],
      time: data['time'],
      steps: List<Map<String, String>>.from(data['steps']),
    );
  }
  // Firestore에 저장할 때 사용할 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'ID': id,
      'userID': userID,
      'difficulty': difficulty,
      'serving': serving,
      'time': time,
      'foods': foods,
      'themes': themes,
      'methods': methods,
      'recipeName': recipeName,
      'steps': steps.map((step) => {
        'description': step['description'],
        'image': step['image'],
      }).toList(),
      'views': views,
    };
  }
}
  // factory RecipeModel.fromJson(Map<String, dynamic> json) {
  //   return RecipeModel(
  //     id: json['ID'],
  //     userID: json['UserID'],
  //     foods: json['Foods'],
  //     difficulty: json['Difficulty'],
  //     serving: json['Serving'],
  //     time: json['Time'],
  //     themes: json['Themes'],
  //     methods: json['Methods'],
  //     recipeName: json['RecipeName'],
  //     content: json['Content'],
  //     views: json['Views'],
  //   );
  // }
  //
  // Map<String, dynamic> toJson() {
  //   return {
  //     'ID': id,
  //     'UserID': userID,
  //     'Foods': foods,
  //     'Difficulty': difficulty,
  //     'Serving': serving,
  //     'Time': time,
  //     'Themes': themes,
  //     'Methods': methods,
  //     'RecipeName': recipeName,
  //     'Content': content,
  //     'Views': views,
  //   };
  // }
// }

class User {
  final int userID;
  final String nickname;
  final String email;
  final DateTime birthdate;
  final String gender;

  User({
    required this.userID,
    required this.nickname,
    required this.email,
    required this.birthdate,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['UserID'],
      nickname: json['Nickname'],
      email: json['Email'],
      birthdate: DateTime.parse(json['Birthdate']),
      gender: json['Gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userID,
      'Nickname': nickname,
      'Email': email,
      'Birthdate': birthdate.toIso8601String(),
      'Gender': gender,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:food_for_later/themes/custom_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  CustomThemeMode _themeMode = CustomThemeMode.light; // 기본 테마

  CustomThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeModeString = prefs.getString('themeMode') ?? 'light';
    _themeMode = CustomThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == themeModeString,
      orElse: () => CustomThemeMode.light,
    );
    notifyListeners();
  }

  Future<void> toggleTheme(CustomThemeMode mode) async {
    _themeMode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'themeMode', mode == ThemeMode.light ? 'Light' : 'Dark');
    notifyListeners();
  }

  void setThemeMode(CustomThemeMode themeMode) async {
    _themeMode = themeMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode.toString().split('.').last);
    notifyListeners();
  }

  // 다양한 테마를 정의합니다.
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.blue,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
    cardColor: Colors.white,
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.blueAccent),
    ),
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.grey[850],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.deepPurple[700],
      textTheme: ButtonTextTheme.primary,
    ),
    cardColor: Colors.grey[800],
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
  );

  final ThemeData blueTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.lightBlue[50],
    appBarTheme: AppBarTheme(
      color: Colors.blueAccent,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blueAccent,
      textTheme: ButtonTextTheme.primary,
    ),
    cardColor: Colors.blue[100],
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.blue[900]),
      titleLarge: TextStyle(color: Colors.blue[800]),
    ),
  );

  final ThemeData greenTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: Colors.green[50],
    appBarTheme: AppBarTheme(
      color: Colors.green,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.green[700],
      textTheme: ButtonTextTheme.primary,
    ),
    cardColor: Colors.green[100],
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.green[900]),
      titleLarge: TextStyle(color: Colors.green[800]),
    ),
  );

  // 현재 선택된 테마를 반환하는 메서드
  ThemeData get currentTheme {
    switch (_themeMode) {
      case CustomThemeMode.light:
        return lightTheme;
      case CustomThemeMode.dark:
        return darkTheme;
      case CustomThemeMode.blue:
        return blueTheme;
      case CustomThemeMode.green:
        return greenTheme;
      default:
        return lightTheme;
    }
  }
}
// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark, // 앱의 기본 테마
//   primaryColor: Colors.blueGrey[800], //앱의 기본 색상
//   scaffoldBackgroundColor: Colors.black, //Scaffold의 배경색
//   // backgroundColor: Colors.grey[900], //카드나 다이얼로그 같은 배경 요소의 색상
//   cardColor: Colors.grey[850], //Card 위젯의 배경색을 설정
//   textTheme: TextTheme( //기본 본문 텍스트 스타일
//     bodyMedium: TextStyle(color: Colors.white70),
//     // bodyText2: TextStyle(color: Colors.white70),
//     // headline6: TextStyle(color: Colors.white),
//   ),
//   appBarTheme: AppBarTheme( //AppBar에 대한 스타일
//     color: Colors.black87,
//     iconTheme: IconThemeData(color: Colors.white),
//   ),
//   drawerTheme: DrawerThemeData(
//     backgroundColor: Colors.blueGrey[800], // 사이드바 배경색 설정
//   ),
//   buttonTheme: ButtonThemeData( //버튼 스타일을 정의
//     buttonColor: Colors.blueGrey[700],
//     textTheme: ButtonTextTheme.primary,
//   ),
//   colorScheme: ColorScheme.dark().copyWith(
//     primary: Colors.blueAccent, //기본 테마 색상
//     secondary: Colors.tealAccent,  //보조 테마 색상
//   ),
// );

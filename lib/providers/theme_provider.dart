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
    colorScheme: ColorScheme.light().copyWith(
      primary: Colors.blue, // 앱의 주요 색상을 검정색으로 지정
      secondary: Colors.grey, // 필요시 보조 색상을 지정
      brightness: Brightness.light,
    ),
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, //전체 앱의 테마 밝기 모드를 설정
    primaryColor: Colors.black, //앱의 기본 색상을 설정
    scaffoldBackgroundColor: Colors.grey[900], //Scaffold 위젯의 배경색
    appBarTheme: AppBarTheme( //AppBar 위젯의 테마를 설정
      color: Colors.grey[900],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey[850],
      scrimColor: Colors.black54, // Drawer 열릴 때 배경을 덮는 색상
    ),
    buttonTheme: ButtonThemeData( //버튼의 테마를 설정
      buttonColor: Colors.grey[850],
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[850], // 버튼의 배경색
        foregroundColor: Colors.white, // 버튼의 텍스트 색상
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData( //플로팅버튼 스타일
      backgroundColor: Colors.grey[850], // 기본 색상 설정
      foregroundColor: Colors.white, // 아이콘 색상
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[850], // 기본 배경색
      labelStyle: TextStyle(color: Colors.white), // 기본 텍스트
      selectedColor: Colors.white, // 선택된 칩의 배경색
      secondaryLabelStyle: TextStyle(color: Colors.black), // 선택된 칩 텍스트 색상
      disabledColor: Colors.grey[500],
    ),
    // cardColor: Colors.grey[800], //Card 위젯의 배경색을 설정
    textTheme: TextTheme( //앱의 텍스트 테마
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark().copyWith(
        primary: Colors.white, // 주요 배경색
        onPrimary: Colors.black, // 주요 배경위 텍스트나 아이콘색
        primaryContainer: Colors.white, //primary와 유사한 색상이지만, 더 연한 버전
        onPrimaryContainer: Colors.white,
        secondary: Colors.grey, // 보조 배경색
        onSecondary: Colors.black, // 캘렌더 컬러박스 글씨
        surface:  Colors.black, //카드와 같은 표면 색상, 하단 네브바
        onSurface: Colors.white, //드롭박스, 사이드바
        brightness: Brightness.dark
    ),
  );

  final ThemeData blueTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor:Color(0xFF3F668F),
    scaffoldBackgroundColor: Color(0xCF5E7891),
    appBarTheme: AppBarTheme(
      color: Color(0xFF05264E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF05264E),
      scrimColor: Color(0xCF5E7891), // Drawer 열릴 때 배경을 덮는 색상
    ),
    buttonTheme: ButtonThemeData(
      buttonColor:Color(0xFF3F668F),
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3F668F), // 버튼의 배경색
        foregroundColor: Colors.white, // 버튼의 텍스트 색상
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData( //플로팅버튼 스타일
      backgroundColor: Color(0xFF3F668F), // 기본 색상 설정
      foregroundColor: Colors.white, // 아이콘 색상
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF3F668F), // 기본 배경색
      labelStyle: TextStyle(color: Colors.white), // 기본 텍스트
      selectedColor: Color(0xFF05264E), // 선택된 칩의 배경색
      secondaryLabelStyle: TextStyle(color: Colors.white), // 선택된 칩 텍스트 색상
      disabledColor: Colors.grey[500],
    ),
    // cardColor: Colors.blue[100],
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF05264E)),
      titleLarge: TextStyle(color: Color(0xFF05264E)),
    ),
    colorScheme: ColorScheme.dark().copyWith(
        primary: Colors.white, // 주요 배경색
        onPrimary: Color(0xFF05264E), // 주요 배경위 텍스트나 아이콘색
        primaryContainer: Color(0xFF4A7ECA), //primary와 유사한 색상이지만, 더 연한 버전
        onPrimaryContainer: Colors.white,
        secondary: Colors.white, // 보조 배경색
        onSecondary: Color(0xFF05264E), // 캘렌더 컬러박스 글씨
        surface:  Color(0xFF3F668F), //카드와 같은 표면 색상, 하단 네브바
        onSurface: Colors.white, //드롭박스, 사이드바
        brightness: Brightness.dark
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
    colorScheme: ColorScheme.light().copyWith(
      primary: Colors.green, // 앱의 주요 색상을 검정색으로 지정
      secondary: Colors.grey, // 필요시 보조 색상을 지정
      brightness: Brightness.light,
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

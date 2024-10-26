import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/firebase_options.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/home_screen.dart';
import 'package:food_for_later/testStorageUpload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
//Flutter 앱의 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //파이어베이스 프로젝트 설정
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
// 앱 전체를 나타내는 루트 위젯
//StatelessWidget: 상태가 없는 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) { //Flutter는 build() 메서드가 호출될 때마다 화면을 새로 그립니다.
    //MaterialApp: 기본적인 앱 구조를 제공하는 위젯
    return MaterialApp(
      title: '이따뭐먹지',
      theme: ThemeData(
        //themeData: 앱의 전반적인 테마를 정의
        primarySwatch: Colors.lightGreen,
      ),
      // navigatorObservers: [DeleteModeObserver(onPageChange: () {
        // 페이지가 변경될 때 _stopDeleteMode 호출
        // 예시: FridgeMainPage의 상태를 가져와서 _stopDeleteMode를 호출
      // })],
      home: HomeScreen(),  // HomeScreen을 메인 화면으로 설정
      navigatorObservers: [routeObserver],
    );
  }
}

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     testStorageUpload(); // 앱 시작 시 호출
//   }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Firebase Storage Test'),
  //     ),
  //     body: Center(
  //       child: ElevatedButton(
  //         onPressed: () async {
  //           await _pickAndUploadImage(); // 이미지 선택 및 업로드
  //         },
  //         child: Text('Upload Test Image'),
  //       ),
  //     ),
  //   );
  // }

  // 이미지 선택 후 Firebase Storage에 업로드하는 함수
//   Future<void> _pickAndUploadImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       // 이미지 파일 경로 확인
//       print('Picked file path: ${pickedFile.path}');
//
//       // 앱의 로컬 디렉토리로 파일을 복사
//       final Directory appDocDir = await getApplicationDocumentsDirectory();
//       final String localPath = '${appDocDir.path}/${pickedFile.name}';
//       final File localFile = await File(pickedFile.path).copy(localPath);
//
//       // 파일이 복사된 경로 확인
//       print('Local file path: $localPath');
//
//       if (localFile.existsSync()) {
//         print('File exists and ready for upload');
//         try {
//           // 고유한 파일 이름 생성
//           final uniqueFileName = 'test_image_${DateTime.now().millisecondsSinceEpoch}.png';
//           final ref = FirebaseStorage.instance.ref().child('test/$uniqueFileName');
//
//           // 복사된 로컬 파일을 업로드
//           final uploadTask = await ref.putFile(
//             localFile,
//             SettableMetadata(
//               contentType: 'image/jpeg', // 파일 형식에 맞는 content type 설정
//             ),
//           );
//
//           // 다운로드 URL 얻기
//           final downloadUrl = await ref.getDownloadURL();
//           print('Image uploaded successfully. Download URL: $downloadUrl');
//         } catch (e) {
//           print('Error uploading image: $e');
//         }
//       } else {
//         print('File does not exist at the given path');
//       }
//     } else {
//       print('No image selected.');
//     }
//   }
// }

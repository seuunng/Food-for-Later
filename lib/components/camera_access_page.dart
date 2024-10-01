import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class CameraAccessPage extends StatefulWidget {
  @override
  _CameraAccessPageState createState() => _CameraAccessPageState();
}

class _CameraAccessPageState extends State<CameraAccessPage> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    // 카메라 권한 요청
    var cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      print("카메라 권한이 허용되었습니다.");
    } else {
      print("카메라 권한이 거부되었습니다.");
    }

    // 저장소 권한 요청 (Android 11 이하에서만 필요)
    var storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print("저장소 권한이 허용되었습니다.");
    } else {
      print("저장소 권한이 거부되었습니다.");
    }
    // Android 11 이상에서의 MANAGE_EXTERNAL_STORAGE 권한 요청
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 30) {
        var manageStorageStatus = await Permission.manageExternalStorage.request();
        if (manageStorageStatus.isGranted) {
          print("관리자 저장소 권한이 허용되었습니다.");
        } else {
          print("관리자 저장소 권한이 거부되었습니다.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Access')),
      body: Center(child: Text('카메라 및 저장소 접근 권한 요청')),
    );
  }
}
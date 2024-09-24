import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagePickerComponent extends StatefulWidget {
  @override
  _ImagePickerComponentState createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  String? _imageUrl;

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      // Firebase Storage에 이미지 업로드
      try {
        final ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().toString()}.png');
        await ref.putFile(file);

        // 이미지 URL 가져오기
        final downloadUrl = await ref.getDownloadURL();
        setState(() {
          _imageUrl = downloadUrl;
        });
        Navigator.pop(context, _imageUrl);
      } catch (e) {
        print('이미지 업로드 실패: $e');
        Navigator.pop(context, null);
      }
    } else {
      Navigator.pop(context, null); // 선택 취소한 경우 null 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Image Example"),
      ),
      body: Center(
        child: _imageUrl == null
            ? Text("이미지가 업로드되지 않았습니다.")
            : Image.network(_imageUrl!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
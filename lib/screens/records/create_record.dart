import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:image_picker/image_picker.dart';

class CreateRecord extends StatefulWidget {
  final Map<String, dynamic>? recordsData; // 수정 시 전달될 레시피 데이터

  CreateRecord({this.recordsData});
  @override
  _CreateRecordState createState() => _CreateRecordState();
}

class _CreateRecordState extends State<CreateRecord> {
  late TextEditingController stepDescriptionController;
  late TextEditingController stepImageController;
  late TextEditingController categoryController;
  late TextEditingController fieldController;

  late String selectedCategory = '식단';
  late String selectedField = '아침';
  late List<Map<String, dynamic>> recordsWithImages = [];

  // 분류와 그에 따른 구분 데이터를 정의
  final Map<String, List<String>> categoryFieldMap = {
    '식단': ['아침', '점심', '저녁'],
    '운동': ['러닝', '탁구', '스트레칭'],
    '자기개발': ['영어공부', '공부']
  };

  // 이미지 선택을 위한 ImagePicker 인스턴스
  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(
      text: widget.recordsData?['category']?.toString() ?? '식단', // 난이도 초기화
    );
    fieldController = TextEditingController(
      text: widget.recordsData?['field']?.toString() ?? '아침', // 난이도 초기화
    );

    stepDescriptionController = TextEditingController();
    stepImageController = TextEditingController();

    selectedCategory = widget.recordsData?['category']?.toString() ?? '식단';
    selectedField = widget.recordsData?['field']?.toString() ?? '아침';
    recordsWithImages =
        List<Map<String, dynamic>>.from(widget.recordsData?['records'] ?? []);
  }

  // 이미지를 선택하는 메서드
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile; // 선택한 이미지 파일을 저장
      });
    }
  }

  // 입력필드
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // 드롭다운
  Widget _buildDropdown(String label, List<String> options, String currentValue,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: options.contains(currentValue) ? currentValue : options[0],
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  //조리방법과이미지 섹션
  Widget _buildRecordsWithImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기록',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: recordsWithImages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Column(
                children: [
                  Row(
                    children: [
                      Text(recordsWithImages[index]['field'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  SizedBox(width: 10),
                  Text(recordsWithImages[index]['description'] ??
                    ''),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 사진을 왼쪽에 정렬
                  (recordsWithImages[index]['image'] != null &&
                      recordsWithImages[index]['image']!.isNotEmpty)
                   ? Image.file(
                      File(recordsWithImages[index]['image']!),
                      width: 50, height: 50,
                    ): Icon(Icons.image, size: 50), // 사진과 텍스트 사이 간격 추가
                ],
              ),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    recordsWithImages.removeAt(index);
                  });
                },
                child: Icon(Icons.close, size: 18),
              ),
            );
          },
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            _buildDropdown(
                '', categoryFieldMap[selectedCategory]!, selectedField,
                (value) {
              setState(() {
                selectedCategory = value;
              });
            }),
            SizedBox(width: 5.0),
            Expanded(
              child: _buildTextField('기록 내용 입력', stepDescriptionController),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (stepDescriptionController.text.isNotEmpty) {
                  setState(() {
                    recordsWithImages.add({
                      'field': selectedField,
                      'description': stepDescriptionController.text,
                      'image': _imageFile?.path ?? '',
                      'images': <String>[],
                    });
                    stepDescriptionController.clear();
                    _imageFile = null;
                  });
                }
              },
            ),
          ],
        ),
        // 조리 단계와 이미지 추가 입력 필드
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt_outlined),
              onPressed: _pickImage,
            ),
            if (_imageFile != null) ...[
              Image.file(
                File(_imageFile!.path),
                width: 50,
                height: 50,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // 저장 버튼 누르면 레시피 추가 또는 수정 처리
  void _saveRecord() {
    if (widget.recordsData == null) {
      // 새 레시피 추가 로직
      print("기록 추가");
    } else {
      // 기존 레시피 수정 로직
      print("기록 수정");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록하기'),
        actions: [
          TextButton(
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 20, // 글씨 크기를 20으로 설정
              ),
            ),
            onPressed: _saveRecord,
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Flexible(
                //   child: _buildTextField('제목', recipeNameController),
                // ),
                // SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격

                _buildDropdown(
                  '분류',
                  categoryFieldMap.keys.toList(), // 카테고리 목록을 드롭다운에 전달
                  selectedCategory,
                  (value) {
                    setState(() {
                      selectedCategory = value;
                      // 분류 변경 시 구분을 첫 번째 값으로 초기화
                      selectedField = categoryFieldMap[selectedCategory]!.first;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildRecordsWithImagesSection(),
          ],
        ),
      ),
    );
  }
}

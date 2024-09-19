import 'dart:io';
import 'dart:typed_data';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

class CreateRecord extends StatefulWidget {
  final Map<String, dynamic>? recordsData;
  final bool isEditing;

  CreateRecord({this.recordsData, this.isEditing = false});
  @override
  _CreateRecordState createState() => _CreateRecordState();
}

class _CreateRecordState extends State<CreateRecord> {
  // late TextEditingController stepDescriptionController;
  late TextEditingController categoryController;
  late TextEditingController fieldController;
  late TextEditingController contentsController;
  late TextEditingController dateController;

  late String selectedCategory = '식단';
  late String selectedField = '아침';
  late String selectedContents = '양배추 참치덮밥';
  late List<Map<String, dynamic>> recordsWithImages = [];
  DateTime selectedDate = DateTime.now();

  // 분류와 그에 따른 구분 데이터를 정의
  final Map<String, List<String>> categoryFieldMap = {
    '식단': ['아침', '점심', '저녁'],
    '운동': ['러닝', '탁구', '스트레칭'],
    '자기개발': ['영어공부', '공부']
  };

  // 이미지 선택을 위한 ImagePicker 인스턴스
  List<AssetEntity> images = [];

  List<XFile>? _imageFiles = [];

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController();
    fieldController = TextEditingController();
    dateController = TextEditingController();
    contentsController = TextEditingController();
    // stepDescriptionController = TextEditingController();

    if (widget.isEditing && widget.recordsData != null) {
      final recordData = widget.recordsData!['record'];
      selectedCategory = recordData['zone'] ?? '식단';
      selectedDate = DateTime.tryParse(recordData['date']) ?? DateTime.now();

      categoryController.text = selectedCategory;
      fieldController.text = selectedField;
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);

      // 이미지 리스트 초기화
      if (recordData['records'] != null && recordData['records'].isNotEmpty) {
        recordsWithImages = List<Map<String, dynamic>>.from(
            recordData['records'].map<Map<String, dynamic>>((record) {
              return {
                'field': record['unit'],
                'contents': record['contents'],
                'images': List<String>.from(record['images'] ?? []),
              };
            }).toList());
      }
      // 드롭다운 리스트에 값이 없으면 추가
      if (!categoryFieldMap.containsKey(selectedCategory)) {
        categoryFieldMap[selectedCategory] = [selectedField];
      } else if (!categoryFieldMap[selectedCategory]!.contains(selectedField)) {
        categoryFieldMap[selectedCategory]!.add(selectedField);
      }
    } else {
      // 추가 모드일 경우 현재 날짜 및 기본값 초기화
      categoryController = TextEditingController(
        text: widget.recordsData?['category']?.toString() ?? '식단',
      );
      fieldController = TextEditingController(
        text: widget.recordsData?['field']?.toString() ?? '아침',
      );
      contentsController = TextEditingController(
        text: widget.recordsData?['contents']?.toString() ?? '',
      );
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }

    // selectedCategory = widget.recordsData?['category']?.toString() ?? '식단';
    // selectedField = widget.recordsData?['field']?.toString() ?? '아침';
    // recordsWithImages =
    //     List<Map<String, dynamic>>.from(widget.recordsData?['records'] ?? []);
  }

  // 이미지를 선택하는 메서드
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();

    // 카메라 또는 갤러리에서 이미지 선택
    List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles = selectedImages; // 선택된 이미지를 리스트에 저장
      });
    }
    print("Selected Images: $_imageFiles");
  }

  // 입력필드
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child:  TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onTap: onTap, // 필요 시 추가된 onTap 이벤트
      ),
    );
  }

  // 날짜 선택 메서드
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // 기본값: 오늘 날짜
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd')
            .format(selectedDate); // 선택한 날짜를 포맷팅하여 텍스트 필드에 입력
      });
    }
  }

  // 날짜 입력 필드 빌드
  Widget _buildDateField() {
    return _buildTextField(
      '날짜 입력',
      dateController,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            dateController.text = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
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
            value: currentValue, // 현재 선택된 값을 드롭다운의 value로 사용
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

  //기록과이미지 섹션
  Widget _buildRecordsSection() {
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
            final List<String> imagePaths =
                (recordsWithImages[index]['images'] as List<String>?) ?? [];

            return ListTile(
              title: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        recordsWithImages[index]['field'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Text(' | '),
                      SizedBox(width: 4),
                      Text(recordsWithImages[index]['contents'] ?? ''),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              subtitle: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: imagePaths.map<Widget>((imagePath) {
                  return  imagePath.startsWith('assets/')
                      ? Image.asset(
                    imagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image');
                    },
                  )
                      : FutureBuilder(
                    future: File(imagePath).exists(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data == true) {
                        return Image.file(
                          File(imagePath),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text('Error loading image');
                          },
                        );
                      } else {
                        return Text('Image not found');
                      }
                    },
                  );
                }).toList(),
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
                selectedField = value;
              });
            }),
            SizedBox(width: 5.0),
            Expanded(
              child: _buildTextField('기록 내용 입력', contentsController),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (recordsWithImages.length >= 10) {
                  // 최대 10개의 기록만 추가 가능하도록 제한
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('기록은 최대 10개까지만 추가할 수 있습니다.'),
                    ),
                  );
                  return;
                }
                if (contentsController.text.isNotEmpty) {
                  setState(() {
                    recordsWithImages.add({
                      'field': selectedField,
                      'contents': contentsController.text,
                      'images': _imageFiles!.map((image) => image.path).toList()
                    });
                    contentsController.clear();
                    _imageFiles = [];
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
              onPressed: () async {
                if (_imageFiles != null && _imageFiles!.length >= 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('한 기록당 최대 4개의 사진만 추가할 수 있습니다.'),
                    ),
                  );
                  return;
                }

                await _pickImages();

                // 한 기록에 최대 4개의 사진만 추가할 수 있도록 제한
                if (_imageFiles != null && _imageFiles!.length > 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('한 기록당 최대 4개의 사진만 추가할 수 있습니다.'),
                    ),
                  );
                  setState(() {
                    _imageFiles = _imageFiles!.sublist(0, 4); // 초과하는 사진 제거
                  });
                }
              },
            ),
            if (_imageFiles != null && _imageFiles!.isNotEmpty) ...[
              Wrap(
                children: _imageFiles!.map((image) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(
                      File(image.path), // 개별 이미지의 경로에 접근
                      width: 50,
                      height: 50,
                    ),
                  );
                }).toList(),
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
      print("기록 추가");
    } else {
      print("기록 수정");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '기록 수정' : '기록하기'),
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
                Expanded(
                  child: _buildTextField('날짜', dateController, onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dateController.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  }),
                ),
                SizedBox(width: 30),
                _buildDropdown(
                  '',
                  categoryFieldMap.keys.toList(), // 카테고리 목록을 드롭다운에 전달
                  selectedCategory,
                  (value) {
                    setState(() {
                      selectedCategory = value;
                      // 분류 변경 시 구분을 첫 번째 값으로 초기화
                      selectedField = categoryFieldMap[selectedCategory]!.first;
                      fieldController.text = selectedField;
                    });
                  },
                ),
                SizedBox(width: 30),
              ],
            ),
            SizedBox(height: 10),
            _buildRecordsSection(),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recordModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

class CreateRecord extends StatefulWidget {
  final String? recordId; // recordId를 받을 수 있도록 수정
  final bool isEditing;

  CreateRecord({this.recordId, this.isEditing = false});
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
  late Color selectedColor = Colors.grey;
  late String selectedContents = '양배추 참치덮밥';
  late List<Map<String, dynamic>> recordsWithImages = [];
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

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

    if (widget.isEditing && widget.recordId != null) {
      // 기록 수정 모드일 때, recordId를 통해 데이터를 불러와서 초기화
      _loadRecordData(widget.recordId!);
    } else {
      // 추가 모드일 경우 현재 날짜 및 기본값 초기화
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  void _loadRecordData(String recordId) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('record')
        .doc(recordId)
        .get();

    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      final record = RecordModel.fromJson(data, id: recordId);

      setState(() {
        selectedCategory = record.zone ?? '식단';
        selectedField = record.records.first.unit ?? '아침';
        selectedDate = record.date;
        selectedColor =
            Color(int.parse(record.color.replaceFirst('#', '0xff')));
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        recordsWithImages = record.records.map((rec) {
          return {
            'field': rec.unit ?? '',
            'contents': rec.contents ?? '',
            'images': rec.images ?? '',
          };
        }).toList();
      });
    }
  }

  // 이미지를 선택하는 메서드
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      // 이미지 선택이 취소된 경우
      print('No image selected.');
      return;
    }

    // 중복된 이미지 추가 제한
    if (_imageFiles!.any((image) => image.path == pickedFile.path)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미 추가된 이미지입니다.'),
        ),
      );
      return;
    }
    // 한 기록에 최대 4개의 사진만 추가할 수 있도록 제한
    if (_imageFiles != null && _imageFiles!.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('한 기록당 최대 4개의 사진만 추가할 수 있습니다.'),
        ),
      );
      return; // 4개 초과 시 추가하지 않음
    }

    setState(() {
      _imageFiles!.add(pickedFile); // 로컬 경로를 XFile 객체로 변환하여 추가
    });
  }

// 이미지 업로드 메서드
  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];

    if (_imageFiles == null || _imageFiles!.isEmpty) {
      print('No images to upload.');
      return downloadUrls; // 빈 배열 반환
    }

    for (var image in _imageFiles!) {
      File file = File(image.path);
      try {
        final uniqueFileName =
            'record_image_${DateTime.now().millisecondsSinceEpoch}';
        final ref =
            FirebaseStorage.instance.ref().child('images/$uniqueFileName');

        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg', // 이미지 형식에 맞게 설정
        );

        await ref.putFile(file, metadata);
        final downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('이미지 업로드 실패: $e');
      }
    }
    return downloadUrls;
  }

// 저장 버튼 누르면 레시피 추가 또는 수정 처리
  void _saveRecord() async {
    List<String> imageUrls = await _uploadImages();

    // 이미지를 업로드한 후, recordsWithImages에 있는 이미지 경로를 파이어스토리지 URL로 교체합니다.
    if (imageUrls.isNotEmpty) {
      setState(() {
        recordsWithImages = recordsWithImages.map((record) {
          return {
            'field': record['field'],
            'contents': record['contents'],
            'images': [
              ...(record['images'] as List<dynamic>), // 기존 이미지 리스트
              ...imageUrls // 새로운 이미지 URL
            ],
          };
        }).toList();
      });
    }
    ;

    List<RecordDetail> recordDetails = recordsWithImages.map((record) {
      return RecordDetail(
        unit: record['field'],
        contents: record['contents'],
        images: List<String>.from(record['images']),
      );
    }).toList();

    final record = RecordModel(
      id: Uuid().v4(), // 고유 ID 생성
      date: selectedDate,
      color: '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}',
      zone: selectedCategory,
      records: recordDetails,
    );

    try {
      // Firestore에 Record 객체를 저장
      await FirebaseFirestore.instance
          .collection('record') // 'records' 컬렉션에 저장
          .doc(record.id) // 고유 ID를 사용하여 문서 생성
          .set(record.toMap(), SetOptions(merge: true)); // Record 객체를 Map으로 변환하여 저장

      // 성공 메시지 표시 및 이전 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기록이 저장되었습니다.')),
      );
      Navigator.pop(context);
    } catch (e) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기록 저장에 실패했습니다. 다시 시도해주세요.')),
      );
      print('Error saving record: $e');
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

  // 입력필드
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          // border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8.0, // 텍스트 필드 내부 좌우 여백 조절
            vertical: 8.0, // 텍스트 필드 내부 상하 여백 조절
          ),
        ),
        onTap: onTap, // 필요 시 추가된 onTap 이벤트
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
                  // URL과 로컬 파일 구분
                  if (imagePath.startsWith('http')) {
                    return Image.network(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Error loading image');
                      },
                    );
                  } else {
                    return Image.file(
                      File(imagePath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Error loading image');
                      },
                    );
                  }
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
          ],
        ),
        // 조리 단계와 이미지 추가 입력 필드
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt_outlined),
              onPressed: _pickImages, // _pickImages 메서드 호출
            ),
            if (_imageFiles != null && _imageFiles!.isNotEmpty) ...[
              Wrap(
                children: _imageFiles!.map((image) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(
                          File(image.path), // 개별 이미지의 경로에 접근
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageFiles!.remove(image);
                            });
                          },
                          child: Container(
                            color: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
            Spacer(),
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
                    if (widget.isEditing && widget.recordId != null) {
                      // 수정 모드일 때: 선택된 기록을 수정
                      int existingRecordIndex = recordsWithImages.indexWhere((record) =>
                      record['field'] == selectedField &&
                          record['contents'] == contentsController.text);

                      if (existingRecordIndex != -1) {
                        // 기존 기록을 수정
                        recordsWithImages[existingRecordIndex] = {
                          'field': selectedField,
                          'contents': contentsController.text,
                          'images': _imageFiles!.map((image) => image.path).toList(),
                        };
                      } else {
                        // 새 기록 추가
                        recordsWithImages.add({
                          'field': selectedField,
                          'contents': contentsController.text,
                          'images': _imageFiles!.map((image) => image.path).toList(),
                        });
                      }
                    } else {
                      // 추가 모드일 때: 새 기록 추가
                      recordsWithImages.add({
                        'field': selectedField,
                        'contents': contentsController.text,
                        'images': _imageFiles!.map((image) => image.path).toList()
                      });
                    }
                    contentsController.clear();
                    // _imageFiles = [];
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

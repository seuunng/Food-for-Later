import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_model.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipe extends StatefulWidget {
  final Map<String, dynamic>? recipeData; // 수정 시 전달될 레시피 데이터

  AddRecipe({this.recipeData});

  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late TextEditingController recipeNameController;
  late TextEditingController minuteController;
  late TextEditingController stepDescriptionController;
  late TextEditingController stepImageController;
  late TextEditingController ingredientsSearchController;
  late TextEditingController methodsSearchController;
  late TextEditingController themesSearchController;
  late TextEditingController servingsController;
  late TextEditingController difficultyController;

  late int selectedServings = 1;
  late String selectedDifficulty;
  late List<String> ingredients;
  late List<String> cookingSteps;
  late List<String> themes;
  late List<Map<String, String>> stepsWithImages;

  List<String> availableIngredients = [];
  List<String> availableMethods = [];
  List<String> availableThemes = [];

  List<String> filteredIngredients = [];
  List<String> filteredMethods = [];
  List<String> filteredThemes = [];

  List<String> selectedIngredients = [];
  List<String> selectedMethods = [];
  List<String> selectedThemes = []; // 선택된 재료 목록

  List<String>? _imageFiles = [];

  @override
  void initState() {
    super.initState();
    recipeNameController = TextEditingController(
      text: widget.recipeData?['recipeName']?.toString() ?? '',
    );
    minuteController = TextEditingController(
      text: widget.recipeData?['cookTime']?.toString() ?? '0',
    );
    servingsController = TextEditingController(
      text: widget.recipeData?['servings']?.toString() ?? '0', // 기준 인원 초기화
    );
    difficultyController = TextEditingController(
      text: widget.recipeData?['difficulty']?.toString() ?? '중', // 난이도 초기화
    );

    stepDescriptionController = TextEditingController();
    stepImageController = TextEditingController();
    ingredientsSearchController = TextEditingController();
    methodsSearchController = TextEditingController();
    themesSearchController = TextEditingController();

    cookingSteps = List<String>.from(widget.recipeData?['cookingSteps'] ?? []);
    themes = List<String>.from(widget.recipeData?['themes'] ?? []);
    ingredients = List<String>.from(widget.recipeData?['ingredients'] ?? []);
    selectedServings = widget.recipeData?['servings'] ?? 0;
    selectedDifficulty = widget.recipeData?['difficulty']?.toString() ?? '중';
    // cookingSteps = List<String>.from(widget.recipeData?['cookingSteps'] ?? []);
    stepsWithImages =
        List<Map<String, String>>.from(widget.recipeData?['recipeSteps'] ?? []);

    ingredients = [];
    cookingSteps = [];
    themes = [];
    stepsWithImages = [];

    filteredIngredients = [];
    filteredMethods = [];
    filteredThemes = [];

    _loadDataFromFirestore();
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      final ingredientsSnapshot =
          await _db.collection('default_foods_categories').get();
      final List<String> ingredientsData = ingredientsSnapshot.docs
          .expand(
              (doc) => (doc['itemsByCategory'] as List<dynamic>).cast<String>())
          .toList();

      final methodsSnapshot =
          await _db.collection('recipe_method_categories').get();
      final List<String> methodsData = methodsSnapshot.docs
          .expand((doc) => (doc['method'] as List<dynamic>).cast<String>())
          .toList();

      final themesSnapshot =
          await _db.collection('recipe_thema_categories').get();
      final List<String> themesData = themesSnapshot.docs
          .map((doc) => doc['categories']
              as String) // 각 문서의 'categories' 필드를 String으로 가져옴
          .toList();

      setState(() {
        availableIngredients = ingredientsData;
        availableMethods = methodsData;
        availableThemes = themesData;
        filteredIngredients = [];
        filteredMethods = methodsData;
        filteredThemes = themesData;
      });
    } catch (e) {
      print('데이터 로드 실패: $e');
    }
  }

  // 검색어에 따른 필터링 기능
  void _filterItems(String query, List<String> sourceList, String type) {
    setState(() {
      if (query.trim().isEmpty) {
        if (type == 'ingredients') {
          filteredIngredients = sourceList;
        } else if (type == 'methods') {
          filteredMethods = sourceList;
        } else if (type == 'themes') {
          filteredThemes = sourceList;
        }
      } else {
        final normalizedQuery = query.trim().toLowerCase(); // 공백 제거 및 소문자 변환
        if (type == 'ingredients') {
          filteredIngredients = sourceList.where((item) {
            final normalizedItem = item.trim().toLowerCase();
            return normalizedItem.contains(normalizedQuery);
          }).toList();
        } else if (type == 'methods') {
          filteredMethods = sourceList.where((item) {
            final normalizedItem = item.trim().toLowerCase();
            return normalizedItem.contains(normalizedQuery);
          }).toList();
        } else if (type == 'themes') {
          filteredThemes = sourceList.where((item) {
            final normalizedItem = item.trim().toLowerCase();
            return normalizedItem.contains(normalizedQuery);
          }).toList();
        }
      }
    });
   }

  // 선택할 수 있는 검색 입력 필드
  Widget _buildSearchableDropdown(
    String title,
    List<String> items,
    TextEditingController searchController,
    Function(String) onItemSelected,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            SizedBox(
              width: 200,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: '$title 검색',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                onChanged: (value) {
                  // 검색어가 비어있으면 빈 리스트로 설정
                  if (value.isEmpty) {
                    setState(() {
                      filteredIngredients = [];
                    });
                  } else {
                    _filterItems(value, items, type);
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (filteredIngredients.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // spacing: 8,
              children: filteredIngredients.map((item) {
                final bool isSelected = selectedIngredients.contains(item);
                return GestureDetector(
                  onTap: () {
                    onItemSelected(item);
                    searchController.clear();
                    setState(() {
                      filteredIngredients = [];
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.0), // 칩들 간의 간격
                    child: Chip(
                      label: Text(
                        item,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black, // 선택된 항목은 글씨 색을 흰색으로
                        ),
                      ),
                      backgroundColor: isSelected
                          ? Colors.blue
                          : Colors.transparent, // 선택된 항목은 배경색을 파란색으로
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 0.0), // 글자와 테두리 사이의 여백 줄이기
                      labelPadding: EdgeInsets.symmetric(
                          horizontal: 4.0), // 글자와 칩 사이의 여백 줄이기
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

// 선택된 재료 목록을 표시
  Widget _buildselectedItems(List<String> selectedItems) {
    return Wrap(
      spacing: 8,
      children: selectedItems.map((item) {
        return Chip(
          label: Text(item),
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
          labelPadding: EdgeInsets.symmetric(horizontal: 1.0),
          deleteIcon: Icon(Icons.close),
          onDeleted: () {
            setState(() {
              selectedItems.remove(item);
            });
          },
        );
      }).toList(),
    );
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
          // border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8.0, // 텍스트 필드 내부 좌우 여백 조절
            vertical: 8.0, // 텍스트 필드 내부 상하 여백 조절
          ),
        ),
      ),
    );
  }

// 가로 스크롤 가능한 섹션 (조리 방법 및 테마)
  Widget _buildHorizontalScrollSection(
    String title,
    List<String> items,
    List<String> filteredItems, // 검색된 항목을 필터링해서 보여주기 위한 리스트
    TextEditingController searchController,
    List<String> selectedItems,
    Function(String) onItemSelected,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            SizedBox(
              width: 200,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: '$title 검색',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                onChanged: (value) {
                  _filterItems(value, items, type); // 검색어 입력 시 항목 필터링
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredItems.map((item) {
              final bool isSelected = selectedItems.contains(item);
              return GestureDetector(
                onTap: () {
                  if (!selectedItems.contains(item)) {
                    setState(() {
                      selectedItems.add(item);
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.0), // 칩들 간의 간격
                  child: Chip(
                    label: Text(
                      item,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black, // 선택된 항목은 글씨 색을 흰색으로
                      ),
                    ),
                    backgroundColor: isSelected
                        ? Colors.blue
                        : Colors.transparent, // 선택된 항목은 배경색을 파란색으로
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 0.0), // 글자와 테두리 사이의 여백 줄이기
                    labelPadding: EdgeInsets.symmetric(
                        horizontal: 4.0), // 글자와 칩 사이의 여백 줄이기
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

//시간입력 섹션
  Widget _buildTimeInputSection() {
    return Expanded(
        child: _buildTextField('분', minuteController, isNumber: true));
  }

  // 난이도 드롭다운
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
  Widget _buildStepsWithImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '조리 단계',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: stepsWithImages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(stepsWithImages[index]['description'] ?? ''),
              leading: stepsWithImages[index]['image'] != null &&
                      stepsWithImages[index]['image']!.isNotEmpty
                  ? Image.network(stepsWithImages[index]['image']!,
                      width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 50),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    stepsWithImages.removeAt(index);
                  });
                },
                child: Icon(Icons.close, size: 18),
              ),
            );
          },
        ),
        SizedBox(height: 16.0),
        // 조리 단계와 이미지 추가 입력 필드
        Row(
          children: [
            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              ..._imageFiles!.map((imagePath) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        File(imagePath), // 개별 이미지의 경로에 접근
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
                            _imageFiles!.remove(imagePath);
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
            if (_imageFiles == null || _imageFiles!.isEmpty)
              IconButton(
                icon: Icon(Icons.camera_alt_outlined),
                onPressed: _pickImages,
              ),
            Expanded(
              child: _buildTextField('조리 과정 입력', stepDescriptionController),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                if (stepDescriptionController.text.isNotEmpty &&
                    _imageFiles != null &&
                    _imageFiles!.isNotEmpty) {

                  String imageUrl = await uploadImage(File(_imageFiles!.first));

                  if (imageUrl.isNotEmpty) {
                    setState(() {
                      stepsWithImages.add({
                        'description': stepDescriptionController.text,
                        'image': imageUrl,
                      });
                      stepDescriptionController.clear();
                      _imageFiles!.clear();
                    });
                  } else {
                    // 이미지 업로드 실패 메시지 출력
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('이미지 업로드 실패')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('조리 과정과 이미지를 입력해 주세요.')));
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // 저장 버튼 누르면 레시피 추가 또는 수정 처리
  void _saveRecipe() async {
    if (widget.recipeData == null) {
      final newItem = RecipeModel(
        id: _db.collection('recipe').doc().id,
        userID: '사용자 ID',
        difficulty: selectedDifficulty,
        serving: selectedServings,
        time: int.parse(minuteController.text),
        foods: selectedIngredients,
        themes: selectedThemes,
        methods: selectedMethods,
        recipeName: recipeNameController.text,
        steps: stepsWithImages,
      );

      try {
        await _db
            .collection('recipe')
            .doc(newItem.id)
            .set(newItem.toFirestore());
        Navigator.pop(context);
      } catch (e) {
        print('레시피 추가 실패: $e');
      }
    } else {
      // 기존 레시피 수정 로직
      print("레시피 수정");
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final uniqueFileName =
          'recipe_image_${DateTime.now().millisecondsSinceEpoch}';
      final imageRef = storageRef.child('images/recipes/$uniqueFileName');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',  // 이미지의 MIME 타입 설정
      );
      final uploadTask = imageRef.putFile(imageFile, metadata);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return '';
    }
  }

  void addStepWithImage(String description, String imageUrl) {
    setState(() {
      stepsWithImages.add({
        'description': description,
        'image': imageUrl,
      });
    });
  }

  // 이미지를 선택하는 메서드
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles == null || pickedFiles.isEmpty) {
      // 이미지 선택이 취소된 경우
      print('No image selected.');
      return;
    }

    if (_imageFiles == null) {
      _imageFiles = [];
    }

    for (XFile file in pickedFiles) {
      if (!_imageFiles!.contains(file.path)) {
        setState(() {
          _imageFiles!.add(file.path); // 로컬 경로를 XFile 객체로 변환하여 추가
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미 추가된 이미지입니다.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData == null ? '레시피 추가' : '레시피 수정'),
        actions: [
          TextButton(
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 20, // 글씨 크기를 20으로 설정
              ),
            ),
            onPressed: _saveRecipe,
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
          children: [
            _buildTextField('레시피 이름', recipeNameController),
            Row(
              children: [
                Icon(Icons.timer, size: 25), // 아이콘
                SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격
                Container(
                  // flex: 1,
                  child: _buildTimeInputSection(),
                ),
                SizedBox(width: 5),
                Icon(Icons.people, size: 25),
                SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격
                Expanded(
                  flex: 1,
                  child:
                      _buildTextField('인원', servingsController, isNumber: true),
                ),
                SizedBox(width: 5),
                Icon(Icons.emoji_events, size: 25),
                SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격
                Expanded(
                  flex: 2,
                  child: _buildDropdown(
                      '난이도', ['상', '중', '하'], selectedDifficulty, (value) {
                    setState(() {
                      selectedDifficulty = value;
                    });
                  }),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSearchableDropdown(
              '재료', // title
              availableIngredients, // items
              ingredientsSearchController,
              (selectedItem) {
                // onItemSelected
                setState(() {
                  selectedIngredients.add(selectedItem);
                });
              },
              'ingredients',
            ),
            SizedBox(height: 10),
            _buildselectedItems(selectedIngredients), // 선택된 재료 표시
            SizedBox(height: 10),

            _buildHorizontalScrollSection(
              '조리 방법',
              availableMethods,
              filteredMethods,
              methodsSearchController,
              selectedMethods,
              (selectedItem) {
                setState(() {
                  selectedMethods.add(selectedItem);
                });
              },
              'methods',
            ),
            SizedBox(height: 10),
            _buildselectedItems(selectedMethods),
            SizedBox(height: 10),

            _buildHorizontalScrollSection(
                '테마', // title
                availableThemes,
                filteredThemes,
                themesSearchController,
                selectedThemes, (selectedItem) {
              // onItemSelected
              setState(() {
                selectedThemes.add(selectedItem);
              });
            }, 'themes'),
            SizedBox(height: 10),
            _buildselectedItems(selectedThemes),

            SizedBox(height: 10),
            _buildStepsWithImagesSection(),
          ],
        ),
      ),
    );
  }
}

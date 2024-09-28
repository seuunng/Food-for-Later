import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';

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
  late TextEditingController ingredientsController;
  late TextEditingController methodsController;
  late TextEditingController themesController;
  late TextEditingController servingsController;
  late TextEditingController difficultyController;

  late int selectedServings;
  late String selectedDifficulty;
  late List<String> ingredients;
  late List<String> cookingSteps;
  late List<String> themes;
  late List<Map<String, String>> stepsWithImages;

  List<String> availableIngredients = []; // Firestore에서 로드한 재료 목록
  List<String> availableMethods = []; // Firestore에서 로드한 조리 방법 목록
  List<String> availableThemes = []; // Firestore에서 로드한 테마 목록

  List<String> filteredIngredients = []; // 필터링된 재료 목록
  List<String> filteredMethods = []; // 필터링된 조리 방법 목록
  List<String> filteredThemes = []; // 필터링된 테마 목록

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
    ingredientsController = TextEditingController();
    methodsController = TextEditingController();
    themesController = TextEditingController();

    cookingSteps = List<String>.from(widget.recipeData?['cookingSteps'] ?? []);
    themes = List<String>.from(widget.recipeData?['themes'] ?? []);
    ingredients = List<String>.from(widget.recipeData?['ingredients'] ?? []);
    // selectedServings = widget.recipeData?['servings'] ?? 0;
    selectedDifficulty = widget.recipeData?['difficulty']?.toString() ?? '중';
    // cookingSteps = List<String>.from(widget.recipeData?['cookingSteps'] ?? []);
    stepsWithImages =
    List<Map<String, String>>.from(widget.recipeData?['recipeSteps'] ?? []);

    ingredients = [];
    cookingSteps = [];
    themes = [];
    stepsWithImages = [];

    _loadDataFromFirestore();
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      // 재료 데이터 로드
      final ingredientsSnapshot = await _db.collection('ingredients').get();
      final List<String> ingredientsData = ingredientsSnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();

      // 조리 방법 데이터 로드
      final methodsSnapshot = await _db.collection('cooking_methods').get();
      final List<String> methodsData = methodsSnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();

      // 테마 데이터 로드
      final themesSnapshot = await _db.collection('themes').get();
      final List<String> themesData = themesSnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();

      setState(() {
        availableIngredients = ingredientsData;
        availableMethods = methodsData;
        availableThemes = themesData;

        // 초기화 시 전체 데이터를 필터링된 목록으로 설정
        filteredIngredients = availableIngredients;
        filteredMethods = availableMethods;
        filteredThemes = availableThemes;
      });
    } catch (e) {
      print('데이터 로드 실패: $e');
    }
  }
  // 검색어에 따른 필터링 기능
  void _filterItems(String query, List<String> sourceList, List<String> targetList) {
    setState(() {
      if (query.isEmpty) {
        targetList.clear();
        targetList.addAll(sourceList);
      } else {
        targetList.clear();
        targetList.addAll(sourceList.where((item) => item.contains(query)).toList());
      }
    });
  }

  // 선택할 수 있는 검색 입력 필드
  Widget _buildSearchableDropdown(
      String title,
      TextEditingController searchController,
      List<String> items,
      List<String> selectedItems,
      Function(String) onItemSelected) {
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                onChanged: (value) {
                  _filterItems(value, items, items);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            return GestureDetector(
              onTap: () {
                onItemSelected(item);
              },
              child: Chip(
                label: Text(item),
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              ),
            );
          }).toList(),
        ),
        Divider(),
      ],
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

  // 키워드 입력 섹션
  Widget _buildKeywordInputSection(String title,
      TextEditingController controller,
      List<String> items,
      Function(String) onAddItem) {
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
            Container(
              height: 50,
              width: 200,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: '$title 입력',
                  // border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.0, // 텍스트 필드 내부 좌우 여백 조절
                    vertical: 8.0, // 텍스트 필드 내부 상하 여백 조절
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      onAddItem(value);
                      controller.clear(); // 입력 후 텍스트필드 초기화
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 7.0),
        Wrap(
          spacing: 7.0,
          children: items.map((item) {
            return Chip(
              label: Text(
                item,
                style: TextStyle(fontSize: 12), // 텍스트 크기 줄이기
              ),
              padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
              // Chip 크기 줄이기
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  items.remove(item);
                });
              },
            );
          }).toList(),
        ),
        Divider(),
      ],
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
                  ? Image.asset(
                  stepsWithImages[index]['image']!,
                  width: 50, height: 50)
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
            IconButton(
              icon: Icon(Icons.camera_alt_outlined),
              onPressed: () {
                // 저장 동작 구현
              },
            ),
            Expanded(
              child: _buildTextField('조리 과정 입력', stepDescriptionController),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (stepDescriptionController.text.isNotEmpty) {
                  setState(() {
                    stepsWithImages.add({
                      'description': stepDescriptionController.text,
                      // 'image': stepImageController.text,
                    });
                    stepDescriptionController.clear();
                    stepImageController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // 저장 버튼 누르면 레시피 추가 또는 수정 처리
  void _saveRecipe() {
    if (widget.recipeData == null) {
      // 새 레시피 추가 로직
      print("레시피 추가");
    } else {
      // 기존 레시피 수정 로직
      print("레시피 수정");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData == null ? '레시피 추가' : '레시피 수정'),
        actions: [
          TextButton(
            child: Text('저장',
              style: TextStyle(
                fontSize: 20, // 글씨 크기를 20으로 설정
              ),),
            onPressed: _saveRecipe,
          ),
          SizedBox(width: 20,)
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
                Expanded(
                  flex: 1,
                  child: _buildTimeInputSection(),
                ),
                SizedBox(width: 5),
                Icon(Icons.people, size: 25),
                SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격
                Expanded(
                  flex: 1,
                  child: _buildTextField('인원', servingsController,
                      isNumber: true),
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
            _buildSearchableDropdown('재료', ingredientsController, filteredIngredients, ingredients,
                    (selectedItem) {
                  setState(() {
                    ingredients.add(selectedItem);
                  });
                }),
            SizedBox(height: 10),
            _buildKeywordInputSection('조리 방법', methodsController, cookingSteps,
                    (String newItem) {
                  setState(() {
                    cookingSteps.add(newItem);
                  });
                }), // 아이콘
            SizedBox(height: 10),
            _buildKeywordInputSection('테마', themesController, themes,
                    (String newItem) {
                  setState(() {
                    themes.add(newItem);
                  });
                }),
            SizedBox(height: 10),
            _buildStepsWithImagesSection(),
          ],
        ),
      ),
    );
  }
}


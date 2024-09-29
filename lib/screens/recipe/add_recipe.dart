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
  late TextEditingController ingredientsSearchController;
  late TextEditingController methodsSearchController;
  late TextEditingController themesSearchController;
  late TextEditingController servingsController;
  late TextEditingController difficultyController;

  late int selectedServings;
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
    // selectedServings = widget.recipeData?['servings'] ?? 0;
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

      // 데이터 로드 후 출력
      print('로드된 재료 데이터: $ingredientsData');

      setState(() {
        availableIngredients = ingredientsData;
        availableMethods = methodsData;
        availableThemes = themesData;
        filteredIngredients = ingredientsData;
        filteredMethods = methodsData;
        filteredThemes = themesData;
      });
    } catch (e) {
      print('데이터 로드 실패: $e');
    }
  }

  // 검색어에 따른 필터링 기능
  void _filterItems(String query, List<String> sourceList, String type) {
    print("입력된 검색어: $query"); // 검색어 출력
    print("원본 데이터: $sourceList"); // 원본 데이터 출력
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
    print(
        "필터링된 $type: ${type == 'ingredients' ? filteredIngredients : type == 'methods' ? filteredMethods : filteredThemes}");
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
                  _filterItems(value, items, type);
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
                searchController.clear();
                _filterItems('', items, type);
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

// 선택된 재료 목록을 표시
  Widget _buildselectedItems(List<String> selectedItems) {
    return Wrap(
      spacing: 8,
      children: selectedItems.map((item) {
        return Chip(
          label: Text(item),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
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
    List<String> selectedItems,
    Function(String) onItemSelected,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              return GestureDetector(
                onTap: () {
                  if (!selectedItems.contains(item)) {
                    setState(() {
                      selectedItems.add(item);
                    });
                  }
                },
                child: Chip(
                  label: Text(item),
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                ),
              );
            }).toList(),
          ),
        ),
        Divider(),
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

  // 키워드 입력 섹션
  Widget _buildKeywordInputSection(
      String title,
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
                  ? Image.asset(stepsWithImages[index]['image']!,
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
              filteredIngredients, // items
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
              filteredMethods,
              selectedMethods,
              (selectedItem) {
                // onItemSelected
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
                filteredThemes,
                selectedThemes, (selectedItem) {
              // onItemSelected
              setState(() {
                selectedThemes.add(selectedItem);
              });
            },
                'themes'
            ),
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

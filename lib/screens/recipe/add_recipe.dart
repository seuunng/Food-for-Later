import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';

class AddRecipe extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();
  final TextEditingController stepDescriptionController =
      TextEditingController();
  final TextEditingController stepImageController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController methodsController = TextEditingController();
  final TextEditingController themesController = TextEditingController();

  int selectedServings = 2;
  String selectedDifficulty = '중';
  final List<String> ingredients = [];
  final List<String> cookingSteps = [];
  final List<String> themes = [];
  final List<Map<String, String>> stepsWithImages = [];

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
            value: currentValue,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              onChanged(newValue!);
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
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    onAddItem(controller.text); // 컨트롤러에서 텍스트를 가져옴
                    controller.clear();
                  });
                }
              },
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
                style: TextStyle(fontSize: 14), // 텍스트 크기 줄이기
              ),
              padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0), // Chip 크기 줄이기
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  items.remove(item);
                });
              },
            );
          }).toList(),
        ),
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
                      'image': stepImageController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 입력'),
        actions: [
          TextButton(
            child: Text('저장',
              style: TextStyle(
                fontSize: 20, // 글씨 크기를 20으로 설정
              ),),
            onPressed: () {
              // 저장 동작 구현
            },
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
                Flexible(
                  flex: 1,
                  child: _buildTimeInputSection(),
                ),
                SizedBox(width: 5),
                Icon(Icons.people, size: 25),
                SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격
                Flexible(
                  flex: 2,
                  child: _buildTextField('기준 인원', TextEditingController(),
                      isNumber: true),
                ),
                SizedBox(width: 5),
                Icon(Icons.emoji_events, size: 25),
                SizedBox(width: 5), // 아이콘과 입력 필드 사이 간격
                Flexible(
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
            _buildKeywordInputSection('재료', ingredientsController, ingredients,
                (String newItem) {
              setState(() {
                ingredients.add(newItem);
              });
            }), // 아이콘
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
            }), // 아이콘
            SizedBox(height: 10),
            _buildStepsWithImagesSection(),
          ],
        ),
      ),
    );
  }
}

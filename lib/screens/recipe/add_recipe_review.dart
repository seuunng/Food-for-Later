import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';

class AddRecipeReview extends StatefulWidget {
  @override
  _AddRecipeReviewState createState() => _AddRecipeReviewState();
}

class _AddRecipeReviewState extends State<AddRecipeReview> {
  TextEditingController reviewContentController = TextEditingController();
  List<String> selectedImages = [];
  int selectedRating = 0;

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedRating = index + 1;
                });
              },
              child: Icon(
                index < selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40, // 아이콘 크기 설정
              ),
            ),
            if (index != 4) SizedBox(width: 2), // 아이콘 사이 간격 설정
          ],
        );
      }),
    );
  }

  // 사진 추가 버튼 (예시로 로컬 파일 경로 리스트에 추가)
  void _addImage() {
    setState(() {
      selectedImages.add('assets/step1.jpeg'); // 예시 이미지 경로 추가
    });
  }

  // 저장 버튼 클릭 시 처리
  void _saveReview() {
    String reviewContent = reviewContentController.text;

    if (reviewContent.isEmpty || selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 입력해주세요')),
      );
      return;
    }

    Navigator.pop(context);
  }

  Widget _buildReviewsAddSection() {
    return Scaffold(
        appBar: AppBar(
          title: Text('리뷰쓰기'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('즐거운 요리시간 되셨나요?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                SizedBox(height: 16),
                _buildRatingStars(),
                SizedBox(height: 16),
                Center(
                  child: Text('어떤 부분이 좋았나요?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: reviewContentController,
                  decoration: InputDecoration(
                    hintText: '최소 10자 이상 입력해주세요!',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 16),
                TextButton(
                    onPressed: _addImage,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                          color: Colors.deepPurple, width: 1), // 테두리 색상과 두께 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined),
                          SizedBox(width: 10), // 아이콘과 텍스트 간격
                          Text('사진 첨부하기'),
                        ],
                      ),
                    ),
                ),
                if (selectedImages.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: selectedImages.map((imagePath) {
                      return Image.asset(
                        imagePath,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        // 저장 버튼
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReview,
              child: Text('저장하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
                ),
                elevation: 5,
                textStyle: TextStyle(
                  fontSize: 18, // 글씨 크기 조정
                  fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                  letterSpacing: 1.2, //
                ),
                // primary: isDeleteMode ? Colors.red : Colors.blue,
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _buildReviewsAddSection();
  }
}

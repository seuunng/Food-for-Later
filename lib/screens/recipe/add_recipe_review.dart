import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipeReview extends StatefulWidget {
  late final String recipeId;

  AddRecipeReview({
    required this.recipeId,
  });

  @override
  _AddRecipeReviewState createState() => _AddRecipeReviewState();
}

class _AddRecipeReviewState extends State<AddRecipeReview> {
  TextEditingController reviewContentController = TextEditingController();
  List<String> selectedImages = [];
  int selectedRating = 0;
  String userId = '현재 유저아이디';
  List<String>? _imageFiles = [];
  List<String> reviewImages = [];
  String imageUrl = '';

  // 사진 추가 버튼 (예시로 로컬 파일 경로 리스트에 추가)
  Future<String> _addImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final uniqueFileName =
          'recipe_review_image_${DateTime.now().millisecondsSinceEpoch}';
      final imageRef =
          storageRef.child('images/recipe_reviews/$uniqueFileName');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg', // 이미지의 MIME 타입 설정
      );
      final uploadTask = imageRef.putFile(imageFile, metadata);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<String> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles == null || pickedFiles.isEmpty) {
      // 이미지 선택이 취소된 경우
      print('No image selected.');
      return '';
    }

    if (_imageFiles == null) {
      _imageFiles = [];
    }

    for (XFile file in pickedFiles) {
      if (!_imageFiles!.contains(file.path)) {
        setState(() {
          _imageFiles!.add(file.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미 추가된 이미지입니다.'),
          ),
        );
      }
    }
    return _imageFiles!.isNotEmpty ? _imageFiles!.first : '';
  }

  // 저장 버튼 클릭 시 처리
  void _saveReview() async {
    String reviewContent = reviewContentController.text;

    if (reviewContent.isEmpty || selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰를 입력해주세요')),
      );
      return;
    }

    try {
      // Generate unique reviewId
      String reviewId =
          FirebaseFirestore.instance.collection('recipe_reviews').doc().id;

      // Get the current user's ID (assuming Firebase Authentication is used)
      // String userId = FirebaseAuth.instance.currentUser!.uid;

      // Save review to Firestore
      await FirebaseFirestore.instance
          .collection('recipe_reviews')
          .doc(reviewId)
          .set({
        'userId': userId,
        'recipeId': widget.recipeId,
        'reviewId': reviewId,
        'rating': selectedRating,
        'content': reviewContent,
        'images': selectedImages, // Assuming selectedImages contains image URLs
        'timestamp': FieldValue.serverTimestamp(), // Save the current timestamp
      });

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰가 저장되었습니다')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error saving review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 저장 중 오류가 발생했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildReviewsAddSection();
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
                // Row(
                //   children: [
                //     if (reviewImages.length < 4) // 이미지가 4장 미만일 때만 선택 가능
                //       IconButton(
                //         icon: Icon(Icons.camera_alt_outlined),
                //         onPressed: _selectImage, // 이미지 선택 메서드 호출
                //       ),
                //     ...reviewImages.map((imageUrl) {
                //       return Stack(
                //         children: [
                //           Padding(
                //             padding: const EdgeInsets.all(4.0),
                //             child: Image.network(imageUrl,
                //                 width: 50, height: 50, fit: BoxFit.cover),
                //           ),
                //           Positioned(
                //             right: 0,
                //             top: 0,
                //             child: GestureDetector(
                //               onTap: () {
                //                 setState(() {
                //                   reviewImages.remove(imageUrl); // 이미지 삭제
                //                 });
                //               },
                //               child: Container(
                //                 color: Colors.black54,
                //                 child: Icon(Icons.close, size: 18, color: Colors.white),
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     }).toList(),
                //   ],
                // ),
                TextButton(
                  onPressed: () async {
                    String selectedImagePath =
                        await _selectImage(); // 이미지 선택 후 경로 반환
                    File imageFile = File(selectedImagePath);
                    imageUrl = await _addImage(imageFile);
                    if (selectedImagePath.isNotEmpty) { // Firebase에 이미지 업로드
                      if (imageUrl.isNotEmpty) {
                        setState(() {
                          selectedImages.add(imageUrl); // 업로드된 이미지 URL을 리스트에 추가
                        });
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.deepPurple, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                SizedBox(height: 16),
                if (selectedImages.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: selectedImages.map((imagePath) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.network(
                              imagePath, // Firebase에서 불러온 이미지 URL
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.remove(imagePath); // 선택한 이미지 삭제
                                });
                              },
                              child: Container(
                                color: Colors.black54,
                                child: Icon(Icons.close, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
}

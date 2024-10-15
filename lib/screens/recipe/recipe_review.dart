import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';
import 'package:intl/intl.dart';

class RecipeReview extends StatefulWidget {
  late final String recipeId;

  RecipeReview({
    required this.recipeId,
  });
  @override
  _RecipeReviewState createState() => _RecipeReviewState();
}

class _RecipeReviewState extends State<RecipeReview> {
  List<Map<String, dynamic>> recipeReviews = [
    // {
    //   'nickname': '승희네',
    //   'contents': '맛있었습니다!',
    //   'date': '2024-05-17 12:00',
    //   'ratings': '★★★☆☆',
    //   'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    // }
  ];
  TextEditingController reviewContentController = TextEditingController();
  bool isNiced = false; // 이미 좋아요를 눌렀는지 여부

  @override
  void initState() {
    super.initState();
    _loadReviewsFromFirestore();
  }

  void _loadReviewsFromFirestore() async {
    List<Map<String, dynamic>> fetchedReviews = await fetchRecipeReviews();
    setState(() {
      recipeReviews = fetchedReviews;
    });
  }

  Future<List<Map<String, dynamic>>> fetchRecipeReviews() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('recipe_reviews')
          .where('recipeId', isEqualTo: widget.recipeId) // 실제 레시피 ID로 대체
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  void _toggleNiced () {
    setState(() {
      if (isNiced ) {
        isNiced  = false;
      } else {
        isNiced = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewsSection(),
          // _buildReviewsInputSection(),
        ],
      ),
    );
  }
  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('리뷰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 500,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recipeReviews.length,
              itemBuilder: (context, index) {
                final Timestamp timestamp = recipeReviews[index]['timestamp'] ?? Timestamp.now();
                final DateTime dateTime = timestamp.toDate();
                final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(child: Icon(Icons.person)),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipeReviews[index]['userId']!,
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  recipeReviews[index]['rating'].toString(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Spacer(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _toggleNiced,
                                  child: Icon(isNiced? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                      size: 12),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ReportAnIssue(postNo: 1)));
                                  },
                                  child:
                                  Icon(Icons.feedback_outlined, size: 12),
                                ),
                                SizedBox(width: 10),
                                Text('|'),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(30, 20),
                                    tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text('수정',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(30, 20),
                                    tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text('삭제',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          recipeReviews[index]['content']!,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: recipeReviews[index]['images'] != null
                              ? List.generate(
                            recipeReviews[index]['images'].length,
                                (imgIndex) => Image.network(
                              recipeReviews[index]['images'][imgIndex], // 네트워크에서 이미지 불러오기
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image); // 이미지 로딩 실패 시 대체 아이콘
                              },
                            ),
                          )
                              : [Container()], /// images가 null일 경우 빈 컨테이너를 표시
                        ),
                      ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

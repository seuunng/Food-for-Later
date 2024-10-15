import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/add_recipe_review.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';
import 'package:intl/intl.dart';

class RecipeReview extends StatefulWidget {
  late final String recipeId;
  final userId = '현재 유저아이디';

  RecipeReview({
    required this.recipeId,
  });

  @override
  _RecipeReviewState createState() => _RecipeReviewState();
}

class _RecipeReviewState extends State<RecipeReview> {
  List<Map<String, dynamic>> recipeReviews = [];

  TextEditingController reviewContentController = TextEditingController();
  // bool isNiced = false; // 이미 좋아요를 눌렀는지 여부

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
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('recipe_reviews')
              .where('recipeId', isEqualTo: widget.recipeId) // 실제 레시피 ID로 대체
              .get();

      List<Map<String, dynamic>> recipeReviews = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id; // 각 리뷰의 Firestore 문서 ID를 추가
        data['isNiced'] = false; // 기본값 false
        return data;
      }).toList();

      for (int i = 0; i < recipeReviews.length; i++) {
        final String reviewId = recipeReviews[i]['reviewId'];

        // niced_reviews에서 좋아요 상태를 확인
        QuerySnapshot<Map<String, dynamic>> nicedSnapshot =
            await FirebaseFirestore.instance
                .collection('niced_reviews')
                .where('recipeId', isEqualTo: widget.recipeId)
                .where('reviewId', isEqualTo: reviewId)
                .where('userId', isEqualTo: '현재 유저아이디') // 실제 유저 ID로 대체
                .get();

        // 좋아요 상태를 반영
        if (nicedSnapshot.docs.isNotEmpty) {
          recipeReviews[i]['isNiced'] =
              nicedSnapshot.docs.first.data()['isNiced'] ?? false;
        }
      }

      return recipeReviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  void _toggleNiced(int index) async {
    final String reviewId = recipeReviews[index]['reviewId'];

    try {
      // 스크랩 상태 확인을 위한 쿼리
      QuerySnapshot<Map<String, dynamic>> existingScrapedRecipes =
          await FirebaseFirestore.instance
              .collection('niced_reviews')
              .where('recipeId', isEqualTo: widget.recipeId)
              .where('userId', isEqualTo: widget.userId)
              .where('reviewId', isEqualTo: reviewId)
              .get();

      if (existingScrapedRecipes.docs.isEmpty) {
        // 스크랩이 존재하지 않으면 새로 추가
        await FirebaseFirestore.instance.collection('niced_reviews').add({
          'userId': widget.userId,
          'recipeId': widget.recipeId,
          'reviewId': reviewId,
          'isNiced': true,
        });

        setState(() {
          recipeReviews[index]['isNiced'] = true;
        });
      } else {
        // 스크랩이 존재하면 업데이트
        DocumentSnapshot<Map<String, dynamic>> doc =
            existingScrapedRecipes.docs.first;

        await FirebaseFirestore.instance
            .collection('niced_reviews')
            .doc(doc.id)
            .delete();

        setState(() {
          recipeReviews[index]['isNiced'] = false;
        });
      }
    } catch (e) {
      print('Error nicing recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('리뷰 좋아요 처리 중 오류가 발생했습니다.'),
      ));
    }
  }

  Future<void> _deleteReview(int index) async {
    String docId = recipeReviews[index]['docId'];
    bool isNiced = recipeReviews[index]['isNiced'] ?? false;
    final String reviewId = recipeReviews[index]['reviewId'];

    try {
      await FirebaseFirestore.instance
          .collection('recipe_reviews')
          .doc(docId)
          .delete();

      setState(() {
        recipeReviews.removeAt(index); // 삭제 후 목록에서 제거
      });

      if (isNiced) {
        QuerySnapshot<Map<String, dynamic>> nicedReviewSnapshot =
            await FirebaseFirestore.instance
                .collection('niced_reviews')
                .where('recipeId', isEqualTo: widget.recipeId)
                .where('reviewId', isEqualTo: reviewId)
                .where('userId', isEqualTo: widget.userId)
                .get();

        if (nicedReviewSnapshot.docs.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> doc =
              nicedReviewSnapshot.docs.first;
          await FirebaseFirestore.instance
              .collection('niced_reviews')
              .doc(doc.id)
              .delete();
        }
      }

      // 삭제 후 리스트에서 해당 리뷰 제거
      setState(() {
        recipeReviews.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('리뷰가 성공적으로 삭제되었습니다.'),
      ));
    } catch (e) {
      print('Error deleting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('리뷰 삭제 중 오류가 발생했습니다.'),
      ));
    }
  }

  // 삭제 확인 다이얼로그
  Future<void> _confirmDeleteReview(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('리뷰 삭제'),
          content: Text('이 리뷰를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _deleteReview(index); // 리뷰 삭제 호출
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(
        rating,
        (index) => Icon(
          Icons.star,
          color: Colors.amber,
          size: 14,
        ),
      ),
    );
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
                final Timestamp timestamp =
                    recipeReviews[index]['timestamp'] ?? Timestamp.now();
                final DateTime dateTime = timestamp.toDate();
                final String formattedDate =
                    DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                bool isNiced = recipeReviews[index]['isNiced'] ?? false;
                int rating = recipeReviews[index]['rating'];

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
                                _buildRatingStars(rating)
                              ],
                            ),
                            Spacer(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _toggleNiced(index),
                                  child: Icon(
                                      isNiced
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_alt_outlined,
                                      size: 12),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReportAnIssue(postNo: 1)));
                                  },
                                  child:
                                      Icon(Icons.feedback_outlined, size: 12),
                                ),
                                SizedBox(width: 10),
                                Text('|'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddRecipeReview(
                                                    recipeId: widget.recipeId,
                                                  reviewId: recipeReviews[index]['reviewId'],
                                                )));
                                  },
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
                                  onPressed: () => _confirmDeleteReview(index),
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
                                    recipeReviews[index]['images']
                                        [imgIndex], // 네트워크에서 이미지 불러오기
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons
                                          .broken_image); // 이미지 로딩 실패 시 대체 아이콘
                                    },
                                  ),
                                )
                              : [Container()],

                          /// images가 null일 경우 빈 컨테이너를 표시
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

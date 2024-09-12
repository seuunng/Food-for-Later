import 'package:flutter/material.dart';

class RecipeReview extends StatefulWidget {
  @override
  _RecipeReviewState createState() => _RecipeReviewState();
}

class _RecipeReviewState extends State<RecipeReview> {
  List<Map<String, dynamic>> recipeReviews = [
    {
      'nickname': '승희네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17 12:00',
      'ratings': '★★★☆☆',
      'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    },
    {
      'nickname': '지환네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17 11:59',
      'ratings': '★★★★☆',
      'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    },
    {
      'nickname': '옥정네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17 10:30',
      'ratings': '★★★★★',
      'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    },
  ];

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
                                Row(
                                  children: [
                                    Text(
                                      recipeReviews[index]['nickname']!,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(width: 4),
                                    Text('|'),
                                    SizedBox(width: 4),
                                    Text(
                                      recipeReviews[index]['date']!,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Text(
                                  recipeReviews[index]['ratings']!,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Spacer(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // 여기에 동작을 추가하세요.
                                  },
                                  child: Icon(Icons.thumb_up_alt_outlined,
                                      size: 12),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    // 여기에 동작을 추가하세요.
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
                          recipeReviews[index]['contents']!,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: recipeReviews[index]['images'] != null
                              ? List.generate(
                                  recipeReviews[index]['images'].length,
                                  (imgIndex) => Image.asset(
                                    recipeReviews[index]['images'][imgIndex],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : [Container()], // images가 null일 경우 빈 컨테이너를 표시
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewsSection(),
      ],
    );
  }
}

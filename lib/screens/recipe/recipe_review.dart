import 'package:flutter/material.dart';

class RecipeReview extends StatefulWidget {
  @override
  _RecipeReviewState createState() => _RecipeReviewState();
}

class _RecipeReviewState extends State<RecipeReview> {
  List<Map<String, String>> recipeReviews = [
    {
      'nickname': '승희네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17',
      'ratings': '★★★',
      'image': 'assets/step1.jpeg'
    },
    {
      'nickname': '지환네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17',
      'ratings': '★★★★',
      'image': 'assets/step2.jpeg'
    },
    {
      'nickname': '옥정네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17',
      'ratings': '★★★★★',
      'image': 'assets/step3.jpeg'
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recipeReviews.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Column(
                    mainAxisSize: MainAxisSize.min, // 아이콘과 닉네임의 높이를 최소화
                    children: [
                      CircleAvatar(
                          child: Icon(Icons.person)), // 아이콘과 닉네임 사이의 간격
                      Text(
                        recipeReviews[index]['nickname']!,
                        style: TextStyle(fontSize: 12), // 닉네임 폰트 크기 설정
                      ),
                    ],
                  ),
                  // title: Text(recipeReviews[index]['nickname']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(recipeReviews[index]['contents']!),
                              Row(
                                children: [
                                  Text(recipeReviews[index]['date']!),
                                  Container(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                          onPressed: () {}, child: Text('수정')),
                                      width: 50),
                                  Container(
                                      child: TextButton(
                                          onPressed: () {}, child: Text('삭제')),
                                      width: 50),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: recipeReviews[index]['image'] != null
                                ? Image.asset(
                                    recipeReviews[index]['image']!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey,
                                    child:
                                        Icon(Icons.image, color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 스크롤을 위해 감싸기
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewsSection(),
        ],
      ),
    );
  }
}

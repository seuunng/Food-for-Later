import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class ReadRecord extends StatefulWidget {
  @override
  _ReadRecordState createState() => _ReadRecordState();
}

class _ReadRecordState extends State<ReadRecord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록보기'),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset('assets/recipe_image.jpeg',
              height: 400, width: 400, fit: BoxFit.cover), // 요리 완성 사진

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 4),
              Text('|'),
              SizedBox(width: 4),
              Container(),
              Container(
                child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // 버튼 패딩을 없앰
                      minimumSize: Size(40, 30), // 최소 크기 설정
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                    ),
                    child: Text('삭제')),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

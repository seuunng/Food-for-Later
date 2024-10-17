import 'package:flutter/material.dart';
import 'package:food_for_later/components/floating_add_button.dart';
import 'package:food_for_later/screens/records/create_record.dart';
import 'package:food_for_later/screens/records/records_album_view.dart';
import 'package:food_for_later/screens/records/records_calendar_view.dart';
import 'package:food_for_later/screens/records/records_list_view.dart';

class ViewRecordMain extends StatefulWidget {

  @override
  _ViewRecordMainState createState() => _ViewRecordMainState();
}

class _ViewRecordMainState extends State<ViewRecordMain> {
  PageController _pageController = PageController();
  int _currentPage = 0; // 현재 페이지 상태
  final int _totalPages = 3; // 총 페이지 수
  bool isTruth = true;

  void _goToNextTable() {
    if (_currentPage == _totalPages - 1) {
      _pageController.jumpToPage(0);
      setState(() {
        _currentPage = 0;
      });
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousTable() {
    if (_currentPage == 0) {
      _pageController.jumpToPage(_totalPages - 1);
      setState(() {
        _currentPage = _totalPages - 1;
      });
    } else {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  String _getPageTitle() {
    // 페이지 번호에 따라 제목을 반환
    switch (_currentPage) {
      case 0:
        return '앨범형';
      case 1:
        return '달력형';
      case 2:
        return '리스트형';
      default:
        return '트렌드';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 좌측 '기록하기' 텍스트
            Text(
              '기록하기',
              style: TextStyle(fontSize: 20),
            ),

            // 가운데 페이지 제목과 화살표 버튼
            Row(
              children: [
                // 왼쪽 화살표 버튼
                IconButton(
                  onPressed: _goToPreviousTable,
                  icon: Icon(Icons.arrow_left_outlined), // <- 이전 버튼
                ),

                // 가운데 페이지 제목
                Text(
                  _getPageTitle(), // 페이지 제목 함수 호출
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),

                // 오른쪽 화살표 버튼
                IconButton(
                  onPressed: _goToNextTable,
                  icon: Icon(Icons.arrow_right_outlined), // -> 다음 버튼
                ),
              ],
            ),
          ],
        ),
      ),
      body:  Column(
        children: [
          Expanded(
            child: Center(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  RecordsAlbumView(), // 첫 번째 페이지: 인기 키워드
                  RecordsCalendarView(),
                  RecordsListView(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
      FloatingAddButton(
        heroTag: 'record_add_button',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRecord(),
              fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
            ),
          );
        },
      ),
    );
  }
}

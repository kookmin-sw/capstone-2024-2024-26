import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Lent_Conference extends StatefulWidget {
  @override
  _Lentconference createState() => _Lentconference();
}

class _Lentconference extends State<Lent_Conference> {
  @override
  Widget build(BuildContext context) {
    final PageController _pageController = PageController();
    int _currentIndex = 0;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '강의실 대여',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon:
                SvgPicture.asset('assets/icons/back.svg', color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: SvgPicture.asset('assets/icons/notice_none.svg'))
          ],
          backgroundColor: Colors.transparent, // 상단바 배경색
          foregroundColor: Colors.black, //상단바 아이콘색

          //shadowColor: Colors(), 상단바 그림자색
          bottomOpacity: 0.0,
          elevation: 0.0,
          scrolledUnderElevation: 0,

          ///
          // 그림자 없애는거 위에꺼랑 같이 쓰면 됨
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'This is the Lent Teamroom page',
            style: TextStyle(fontSize: 24),
          ),
        ),

        // 하단 바
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10), // 모든 방향으로 바텀 패딩.
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/lent.svg'),
                label: '공간 대여',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/reserved.svg'),
                label: '예약 내역',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/mypage.svg'),
                label: '마이페이지',
              ),
            ],
            selectedLabelStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            selectedItemColor: Colors.black,
          ),
        ));
  }
}

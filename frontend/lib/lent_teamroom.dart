import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Lent_Teamroom extends StatefulWidget {
  @override
  _Lentteam createState() => _Lentteam();
}

class _Lentteam extends State<Lent_Teamroom> {
  @override
  Widget build(BuildContext context) {
    final PageController _pageController = PageController();
    int _currentIndex = 0;
    String time = '09:00 ~ 22:00';
    String people = '12';
    bool _isExpanded = false;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '동아리방 대여',
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
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 353,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.50, color: Color(0xFFE3E3E3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],

                    /// 여기까지 바깥 배경 블락
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset(
                              'assets/images.png',
                              width: 340,
                              height: 160,
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 100.15,
                                height: 36,
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    )),
                                child: TextButton(
                                  onPressed: null,
                                  child: Text(
                                    '동아리방 1',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              right: 20,
                              child: GestureDetector(
                                onTap: () {
                                  // 맵 버튼 눌렀을 때 이동할 화면
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/map.png',
                                      width: 22,
                                      height: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 120,
                              child: GestureDetector(
                                onTap: () {
                                  // 맵 버튼 눌렀을 때 이동할 화면
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/group-fill.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                    Text(
                                      people,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  // 맵 버튼 눌렀을 때 이동할 화면
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/time-fill.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// 예약하기 펼쳐지는 부분
                        ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 45), // Add left padding here
                                child: Text(
                                  '예약하기',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              SizedBox(width: 5), // 텍스트와 아이콘 간격 조절
                              SvgPicture.asset(
                                'assets/icons/narrow_icon.svg',
                              ),
                            ],
                          ),

                          trailing: SizedBox(), // 기본 화살표를 숨깁니다.
                          initiallyExpanded: false,

                          /// 펼쳐졌을 때
                          ///

                          children: <Widget>[
                            ListTile(
                              title: Text('Item 1'),
                              onTap: () {
                                // Add your action here
                              },
                            ),
                            ListTile(
                              title: Text('Item 2'),
                              onTap: () {
                                // Add your action here
                              },
                            ),
                            // Add more ListTiles as needed
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

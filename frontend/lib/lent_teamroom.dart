import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart'; // 필요시 main.dart 파일을 import합니다.
import 'loading.dart'; // 로딩 화면을 표시하는 데 사용할 LoadingScreen 위젯을 import합니다.
import 'select_reserve.dart'; // 예약 페이지를 보여주는 데 사용할 Select_reserve 위젯을 import합니다.
import 'myPage.dart'; // 마이페이지를 보여주는 데 사용할 MyPage 위젯을 import합니다.
import 'reservation_details.dart';

class Lent_Teamroom extends StatefulWidget {
  @override
  _Lentteam createState() => _Lentteam();
}

class _Lentteam extends State<Lent_Teamroom> {
  final ExpansionTileController controller = ExpansionTileController();

  String time = ''; //server
  String people = ''; //server
  String room_name = ''; //server
  String room_count = ''; // server
  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '공간대여',
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
              icon: SvgPicture.asset('assets/icons/notice_none.svg'),
            ),
          ],
          backgroundColor: Colors.transparent, // 상단바 배경색
          foregroundColor: Colors.black, //상단바 아이콘색
          bottomOpacity: 0.0,
          elevation: 0.0,
          scrolledUnderElevation: 0,
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
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
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Image.asset(
                                'assets/images.png',
                                width: 340.63,
                                height: 164.03,
                              ),
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
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: null,
                                  child: Text(
                                    room_name,
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
                              bottom: 12,
                              right: 18,
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
                              top: 15,
                              right: 105,
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 15,
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Select_reserve(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(340.75, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            elevation: 0, // Remove button shadow
                          ),
                          child: Text(
                            isLoading ? '로딩 중...' : '예약하기',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // Adjust the index according to your need
          onTap: (index) {
            switch (index) {
              case 0:
                break;

              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Details()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
                break;
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/lent.svg'),
              label: '공간대여',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/reserved.svg'),
              label: '예약내역',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/mypage.svg'),
              label: '마이페이지',
            ),
          ],
          selectedLabelStyle:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 13),

          selectedItemColor: Colors.black,
          unselectedLabelStyle:
              TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          unselectedItemColor: Colors.grey,
        ),
      );
    }
  }
}

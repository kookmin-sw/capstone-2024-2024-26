import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/sign_in.dart';
import 'package:frontend/loading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/lent_teamroom.dart';
import 'package:frontend/lent_conference.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 사용자 탭 감지 키보드 내려감
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
      },
      child: MaterialApp(
        title: 'keyboard unfocus',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      });
    } else {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

// 메인페이지 ( 대여공간 선택 창 )
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 중간 바디부분

    return Scaffold(
        appBar: AppBar(
          title: Text(
            '대여 공간 선택',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '대여하실 공간을 선택해주세요.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(180, 240),
                      backgroundColor: Color(0xFFF7F7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Lent_Teamroom()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Image.asset(
                          'assets/lentgroup.png',
                          width: 113,
                          height: 101,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text('동아리방 대여',
                            style: TextStyle(
                              fontSize: 18.75,
                              color: Color(0xFF006282),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(180, 240),
                      backgroundColor: Color(0xFFF7F7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Lent_Conference()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Image.asset(
                          'assets/lentroom.png',
                          width: 113,
                          height: 101,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text('강의실 대여',
                            style: TextStyle(
                              fontSize: 18.75,
                              color: Color(0xFF006282),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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

  void addClick() {
    setState(() {
      _currentIndex = 1;
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}

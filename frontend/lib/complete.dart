import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/main.dart';

import 'loading.dart';

import 'package:dotted_line/dotted_line.dart';
import 'myPage.dart';
import 'reservation_details.dart';
import 'congestion.dart';

class Complete extends StatefulWidget {
  const Complete({super.key});

  @override
  _Complete createState() => _Complete();
}

class _Complete extends State<Complete> {
  final PageController _pageController = PageController();
  final ExpansionTileController controller = ExpansionTileController();
  final int _currentIndex = 0;

  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
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
          shape: const Border(
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
              const Text(
                '    예약이 완료되었습니다.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 0.09,
                ),
              ),
              const SizedBox(height: 30),
              SvgPicture.asset('assets/icons/completion.svg'),
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/Subtract.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 35),
                      const Text(
                        '[ 미래관 610호 ]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '2024.3.19(화)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF004F9E),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '오후 12:00 ~ 3:00  | 8인 | 좌석 2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                      const SizedBox(height: 23),
                      const DottedLine(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        lineLength: 200,
                        lineThickness: 0.5,
                        dashLength: 3.0,
                        dashColor: Colors.grey,
                        dashRadius: 0.0,
                        dashGapLength: 6.0,
                        dashGapColor: Colors.transparent,
                        dashGapRadius: 0.0,
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Details()),
                          );
                        },
                        child: const Text(
                          '예약내역 확인하기',
                          style: TextStyle(
                            color: Color(0xFF004F9E),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            height: 0.18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // 하단 바
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,

          currentIndex: 0, // Adjust the index according to your need
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
                break;

              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Congestion()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Details()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPage()),
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
              icon: SvgPicture.asset('assets/icons/congestion_off.svg'),
              label: '혼잡도',
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
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          selectedItemColor: Colors.black,
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          unselectedItemColor: Colors.grey,
        ),
      );
    }
  }
}

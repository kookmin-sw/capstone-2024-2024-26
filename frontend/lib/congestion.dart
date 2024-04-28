import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'settings.dart';
import 'main.dart';
import 'reservation_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'myPage.dart';

enum MenuType { first, second, third }

class Congestion extends StatefulWidget {
  const Congestion({super.key});

  @override
  _CongestionState createState() => _CongestionState();
}

class _CongestionState extends State<Congestion> {
  List<Map<String, String>> congestionData = [
    {
      'location': 'Study Rounge',
      'location_detail': '미래관 4층',
      'congestion': '매우 혼잡',
      'color': '0XFFD30000'
    },
    {
      'location': '자율주행스튜디오',
      'location_detail': '미래관 4층',
      'congestion': '보통',
      'color': '0XFF00A61B'
    },
    {
      'location': '무한상상실',
      'location_detail': '미래관 4층',
      'congestion': '여유',
      'color': '0XFF0081B9'
    },
    {
      'location': '블루파빌리온',
      'location_detail': '북악관 1층',
      'congestion': '혼잡',
      'color': '0XFFEF7300'
    },
    // 다른 위치 데이터도 추가할 수 있음
  ];

  final _values = [
    '전체',
    '북악관',
    '미래관',
    '공학관',
    '복지관',
    '예술관',
    '과학관',
    '본부관',
    '법학관',
    '조형관'
  ];
  final _sortValues = ['혼잡도 높은 순', '혼잡도 낮은 순'];

  String _selectedValue = '';
  String _selectedSortValue = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedValue = _values[0];
      _selectedSortValue = _sortValues[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '혼잡도',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Container(),
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
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(right: 270),
              child: Text(
                '실시간 혼잡도',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: SvgPicture.asset(
                    'assets/icons/congestion_bar.svg',
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Container(
                  width: 83,
                  child: ButtonTheme(
                    alignedDropdown:
                        true, // DropdownButton의 너비를 ButtonTheme에 맞게 조정합니다.
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedValue,
                      items: _values
                          .map((e) => DropdownMenuItem(
                                value: e, // 선택 시 onChanged 를 통해 반환할 value
                                child: Text(e,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                    )),
                              ))
                          .toList(),
                      onChanged: (value) {
                        // items 의 DropdownMenuItem 의 value 반환
                        setState(() {
                          _selectedValue = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 120,
                  child: ButtonTheme(
                    alignedDropdown:
                        true, // DropdownButton의 너비를 ButtonTheme에 맞게 조정합니다.
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedSortValue,
                      items: _sortValues
                          .map((e) => DropdownMenuItem(
                                value: e, // 선택 시 onChanged 를 통해 반환할 value
                                child: Text(e,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                    )),
                              ))
                          .toList(),
                      onChanged: (value) {
                        // items 의 DropdownMenuItem 의 value 반환
                        setState(() {
                          _selectedSortValue = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: congestionData.length,
              itemBuilder: (context, index) {
                print(index); // Add this line to print the index to the console
                final data = congestionData[index];
                print(data);
                return Column(
                  children: [
                    SizedBox(height: 10), // Add spacing here

                    _CustomScrollViewWidget(
                      location: data['location']!,
                      location_detail: data['location_detail']!,
                      congestion: data['congestion']!,
                      color: data['color']!,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        currentIndex: 1, // Adjust the index according to your need
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
              break;

            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Details()),
              );
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
            icon: SvgPicture.asset('assets/icons/lent_off.svg'),
            label: '공간대여',
          ),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/congestion.svg'),
              label: '혼잡도'),
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

        selectedItemColor: const Color.fromARGB(255, 158, 136, 136),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // 버튼을 생성하는 함수
  Widget _buildButton(String label, VoidCallback onPressed) {
    return Container(
      // 버튼을 Container로 감싸서 margin 설정
      margin: const EdgeInsets.only(left: 20), // 왼쪽에만 margin 설정
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // Divider를 생성하는 함수
  Widget _buildDivider() {
    return const Divider(
      thickness: 1, // 실선의 두께를 지정
      color: Colors.grey, // 실선의 색상을 지정
      indent: 20, // 시작점에서의 들여쓰기
      endIndent: 20, // 끝점에서의 들여쓰기
    );
  }
}

class _CustomScrollViewWidget extends StatelessWidget {
  final String location;
  final String location_detail;
  final String congestion;
  final String color;

  const _CustomScrollViewWidget({
    Key? key,
    required this.location,
    required this.location_detail,
    required this.congestion,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: 361.65,
          height: 54,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.50, color: Color(0xFFFFFFFF)),
              borderRadius: BorderRadius.circular(2),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                child: Text(
                  '     ' + location,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                '|  ' + location_detail,
                style: TextStyle(
                  color: Color(0XFFADADAD),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(), // 추가된 부분
              Container(
                alignment: Alignment.center,
                width: 67,
                height: 30,
                decoration: ShapeDecoration(
                  color: Color(0x00D9D9D9),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFE3E3E3)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  congestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(int.parse(color.substring(2), radix: 16)),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

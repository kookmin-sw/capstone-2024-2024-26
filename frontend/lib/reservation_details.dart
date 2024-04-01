import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'alert.dart';
import 'settings.dart';
import 'main.dart';
import 'myPage.dart';

class Details extends StatefulWidget {
  @override
  _Details createState() => _Details();
}

class _Details extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '예약 내역',
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
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
          // SingleChildScrollView로 감싸서 스크롤 가능하도록

          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Adjust the index according to your need
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
              break;

            case 1:
              // Handle navigation to the second screen
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
            icon: SvgPicture.asset('assets/icons/lent_1.svg'),
            label: '대여하기',
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

  // 버튼을 생성하는 함수
  Widget _buildButton(String label, VoidCallback onPressed) {
    return Container(
      // 버튼을 Container로 감싸서 margin 설정
      margin: EdgeInsets.only(left: 20), // 왼쪽에만 margin 설정
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // Divider를 생성하는 함수
  Widget _buildDivider() {
    return Divider(
      thickness: 1, // 실선의 두께를 지정
      color: Colors.grey, // 실선의 색상을 지정
      indent: 20, // 시작점에서의 들여쓰기
      endIndent: 20, // 끝점에서의 들여쓰기
    );
  }
}

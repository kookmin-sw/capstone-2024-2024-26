import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

class AlertPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('알림'),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 8), // Divider 아래 여백 조정
          Text(
            '알림 데이터 작업 완료되면 페이지 수정 예정',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Adjust the index according to your need
        onTap: (index) {
          switch (index) {
            case 0:
              // Handle navigation to the first screen
              break;
            case 1:
              // Handle navigation to the second screen
              break;
            case 2:
              // Handle navigation to the third screen (current screen)
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
            label: '예약 내역',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/mypageB.svg'),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
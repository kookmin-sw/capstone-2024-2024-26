import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'alert.dart';
import 'settings.dart';
import 'main.dart';
import 'myPage.dart';
import 'package:dotted_line/dotted_line.dart';

class Details extends StatefulWidget {
  @override
  _Details createState() => _Details();
}

class _Details extends State<Details> {
  @override
  Widget build(BuildContext context) {
    bool isLent = false;
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
          child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 20)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30), // Adjust the value as needed
              child: Text(
                '이용 예정',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF004F9E),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/Subtract2.png'),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 13),
                  Text(
                    '[ 미래관 610호 ]',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 13),
                  DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineLength: 300,
                    lineThickness: 0.5,
                    dashLength: 3.0,
                    dashColor: Colors.grey,
                    dashRadius: 0.0,
                    dashGapLength: 6.0,
                    dashGapColor: Colors.transparent,
                    dashGapRadius: 0.0,
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 50), // Adjust the value as needed
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '날짜  2024.3.19(화)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF004F9E),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 50), // Adjust the value as needed
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '오후  12:00~15:00' + '  |  ' + '좌석 T1',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7C7C7C),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => FlutterDialog("입장하시겠습니까?", "입장하기"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004F9E),
                      minimumSize: const Size(330.11, 57.06),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(
                      isLent ? '반납하기' : '입장하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 1, // 선의 높이 조정
                    width: 350, // 선의 너비 조정
                    color:
                        Colors.grey.withOpacity(0.2), // 투명도를 조정하여 희미한 색상으로 설정
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () =>
                              FlutterDialog("예약을 변경하시겠습니까 ?", "변경하기"),
                          child: Text(
                            '예약 변경',
                            style: TextStyle(
                              color: Color(0xFF8E8E8E),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 60),
                        Container(
                          height: 34.74, // 선의 높이 조정
                          width: 1, // 선의 너비 조정
                          color: Colors.grey
                              .withOpacity(0.2), // 투명도를 조정하여 희미한 색상으로 설정
                        ),
                        SizedBox(width: 60),
                        TextButton(
                          onPressed: () =>
                              FlutterDialog("예약을 취소하시겠습니까 ?", "예약 취소"),
                          child: Text(
                            '예약 취소',
                            style: TextStyle(
                              color: Color(0xFF8E8E8E),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          DottedLine(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            lineLength: 350,
            lineThickness: 0.5,
            dashLength: 3.0,
            dashColor: Colors.grey,
            dashRadius: 0.0,
            dashGapLength: 6.0,
            dashGapColor: Colors.transparent,
            dashGapRadius: 0.0,
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30), // Adjust the value as needed
              child: Text(
                '이용 내역',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/Subtract3.png'),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '[ 미래관 610호 ]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 110),
                      Container(
                        height: 20.87, // 선의 높이 조정
                        width: 1, // 선의 너비 조정
                        color: Colors.grey
                            .withOpacity(0.2), // 투명도를 조정하여 희미한 색상으로 설정
                      ),
                      SizedBox(width: 30),
                      Text(
                        '이용 완료',
                        style: TextStyle(
                          color: Color(0XFF484848),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineLength: 300,
                    lineThickness: 0.5,
                    dashLength: 3.0,
                    dashColor: Colors.grey,
                    dashRadius: 0.0,
                    dashGapLength: 6.0,
                    dashGapColor: Colors.transparent,
                    dashGapRadius: 0.0,
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 50), // Adjust the value as needed
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '날짜  2024.3.19(화)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF004F9E),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 50), // Adjust the value as needed
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '오후  12:00~15:00' + '  |  ' + '좌석 T1',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7C7C7C),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.21,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 45),
                ],
              ),
            ],
          ),
        ],
      )),
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
            icon: SvgPicture.asset('assets/icons/lent_off.svg'),
            label: '공간대여',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/reserved_on.svg'),
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

  //alert dialog
  void FlutterDialog(String text, String text2) {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
            //Dialog Main Title

            //
            content: Container(
              width: 359.39,
              height: 40.41, // Dialog 박스의 너비 조정
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            actions: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 1, // 선의 높이 조정
                    width: 350, // 선의 너비 조정
                    color:
                        Colors.grey.withOpacity(0.2), // 투명도를 조정하여 희미한 색상으로 설정
                  ),
                  Row(
                    children: [
                      SizedBox(width: 30),
                      TextButton(
                        child: new Text("돌아가기",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 50), // 버튼 사이 간격 조정
                      Container(
                        height: 34.74, // 선의 높이 조정
                        width: 1, // 선의 너비 조정
                        color: Colors.grey
                            .withOpacity(0.2), // 투명도를 조정하여 희미한 색상으로 설정
                      ),
                      SizedBox(width: 50), // 버튼 사이 간격 조정
                      TextButton(
                        child: new Text(text2,
                            style: TextStyle(
                              color: Color(0XFF004F9E),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              )
            ],
          );
        });
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

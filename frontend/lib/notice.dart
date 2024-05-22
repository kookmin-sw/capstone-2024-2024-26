import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:frontend/sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'settings.dart';
import 'main.dart';
import 'reservation_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'congestion.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyNotice extends StatefulWidget {
  const MyNotice({super.key});

  @override
  _MyNoticeState createState() => _MyNoticeState();
}

class _MyNoticeState extends State<MyNotice> {
  List<dynamic> notifications = [
    {'title': '이용알림', 'body': '🔔 232호 반납이 완료되었습니다.', 'date': '5월 21일 13:00'},
    {
      'title': '긴급',
      'body': '🚨 신청한 강의실이 611호->232호로 변경되었습니다.',
      'date': '5월 21일 12:50'
    },
    {'title': '이용알림', 'body': '🔔 12시 이용 예정이 되어 있습니다.', 'date': '5월 21일 11:50'},
    {'title': '공지사항', 'body': '🛠 1.12 기능 업데이트', 'date': '5월 21일 11:00'}
  ]; // 서버에서 받아온 알림 데이터를 저장할 리스트

  String name = '';
  String club = '';
  String? studentId;
  String? penalty;
  @override
  void initState() {
    super.initState();
    _checkUidStatus();
    // fetchNotifications(); // 화면 로딩 시 알림 데이터를 가져옵니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/back.svg', color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,

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
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              notifications[index]['title'],
            ),
            subtitle: Text(notifications[index]['body']),
            trailing: Text(notifications[index]['date']),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Adjust the index according to your need
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
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/lent_off.svg'),
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
            icon: SvgPicture.asset('assets/icons/mypageB.svg'),
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

  void _flutterDialog(BuildContext context, String text, String text2) {
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
            content: SizedBox(
              width: 359.39,
              height: 45.41, // Dialog 박스의 너비 조정
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    text,
                    style: const TextStyle(
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
                      const SizedBox(width: 35),
                      TextButton(
                        child: const Text("돌아가기",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 35), // 버튼 사이 간격 조정
                      Container(
                        height: 34.74, // 선의 높이 조정
                        width: 1, // 선의 너비 조정
                        color: Colors.grey
                            .withOpacity(0.2), // 투명도를 조정하여 희미한 색상으로 설정
                      ),
                      SizedBox(width: 50), // 버튼 사이 간격 조정
                      TextButton(
                        child: Text(text2,
                            style: const TextStyle(
                              color: Color(0XFF004F9E),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.remove('uid');
                            prefs.setString('token', 'false');
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
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

  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    const url = 'http://3.35.96.145:3000/auth/profile/:uid';

    final Map<String, String> data = {
      'uid': uid ?? '',
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'User checking success') {
        setState(() {
          name = responseData['userData']['name'];
          club = responseData['userData']['club'];
          studentId = responseData['userData']['studentId'];
        });
      } else {}
    } else {
      setState(() {
        String errorMessage = ''; // Define the variable errorMessage
        errorMessage = '아이디와 비밀번호를 확인해주세요';
      });
    }
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

  //alert dialog
}

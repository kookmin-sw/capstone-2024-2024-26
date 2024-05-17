import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:frontend/question.dart';
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
import 'notice.dart';
import 'question.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String name = '';
  String club = '';
  bool isAgreed = false;
  String? studentId;
  String? penalty;
  @override
  void initState() {
    super.initState();
    _checkUidStatus();
  }

  void _showGuidanceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isChecked = false; // 체크박스 상태 관리용 변수
        return Dialog(
          backgroundColor: Colors.transparent, // Dialog 배경을 투명하게 설정
          child: Container(
            width: 1500, // 다이얼로그의 너비 설정
            height: 700, // 다이얼로그의 높이 설정
            decoration: BoxDecoration(
                color: Colors.white, // 다이얼로그의 배경색 지정
                borderRadius: BorderRadius.circular(4) // 모서리를 직각으로 설정
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "이용안내",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Text(
                      "\n* 공유공간은 학생들이 그룹 스터디, 토론,\n 조별과제 등의 팀 단위 학업 수행을 위해 마련된 \n공간으로 팀 단위 당 하루 최대 4시간을 예약하여 \n이용하실 수 있습니다.\n\n* 강의실 신청자는 학생증(신분증)을 필히 지참하여 당직근무자가 확인을 위하여 학생증\n 제시를 요구할 시 이에 응하여야 하며, 당직근무자의 지시에 순응하여야 한다.\n* 화재 및 안전사고 예방에 주의해야 하며 전열기 및 위험물질의 사용을 금합니다.\n* 강의실 사용 목적 이외의 행위(취사 및 음주)를 금합니다.\n* 강의실 사용 중에 비품 및 기자재의 파손 및 망실에 대한 책임은 \n[교내 물품 관리 규정] 제14조에 의거합니다.\n* 강의실 내에 설치된 비품 및 기자재 보존과 청결을 유지할 것을 약속합니다.\n* 강의실 사용 시 음식물 반입을 금지합니다.\n* 대여 가능한 기간은 최장 5일입니다(주말 제외).\n\n주의사항\n\n1.예약 신청 후 사전 취소 없이 2회 공간 미이용 시 \n시설 이용 페널티가 발생합니다.\n2.페널티 2회 이상 부여 받을 시에는 60일의 \n시설 이용이 정지됩니다. \n3.예약 신청 시간 이후 10분 내에 입실하지 않을 시에 \n예약 취소되며 다음 대기자에게 자동 예약됩니다.\n 4.음식물 취식 가능 여부 등은 해당 공간의 \n규칙에 따라 상이합니다.\n 5.사용 후 정리 정돈 및 사진 촬영은 필수이며 이행하지 \n않을 시에는 페널티가 부여됩니다. \n6.정리 정돈 사진은 AI에 의해 통과 여부가 판단됩니다. ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: const Color(0xFF004F9E),
                      value: isChecked,
                      onChanged: (bool? value) {
                        // 체크박스 상태를 업데이트하고 다이얼로그를 닫음
                        setState(() {
                          isChecked = value!;
                        });
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                    ),
                    Text(
                      "이해했습니다.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0XFF004F9E),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                if (isAgreed) // 체크박스가 체크되면 버튼 표시
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                    child: Text("확인"),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyNotice()),
              );
            },
            icon: SvgPicture.asset('assets/icons/notice_none.svg'),
          ),
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
            const SizedBox(height: 20),
            Container(
              width: 337,
              height: 132.76,
              decoration: BoxDecoration(
                color: const Color(0x079A9A9A),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0XF5F5F5F5),
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Color(0XC8C8C8C8),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10), // 이름 div의 top margin 추가
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // 글씨 크기 조정
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Text(' 님',
                              style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 16)),
                          SizedBox(
                            width: 70,
                          ),
                          IconButton(
                            onPressed: () {
                              _flutterDialog(context, '수정이 제한되었습니다.', '확인');
                            },
                            icon: SvgPicture.asset(
                              'assets/icons/settings.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              club,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // 글씨 크기 조정
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, bottom: 10),
                            child: Text(
                              '패널티 0회', // 동아리 이름과 패널티 표시
                              style: TextStyle(
                                color: Colors.grey[600], // 연한 회색으로 지정
                                fontSize: 12, // 글씨 크기 조정
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Text(
                              '학번',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            ' $studentId',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // '이용안내, 문의하기, 로그아웃' 버튼과 회색원 간격 추가
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => {
                    _showGuidanceDialog(context),
                  },
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent, // Remove shadow color
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    '     이용안내',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDivider(),
                TextButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuestionPage()),
                    )
                  },
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent, // Remove shadow color
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    '     문의하기',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDivider(),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => {
                        _flutterDialog(context, "로그아웃 하시겠습니까?", "로그아웃"),
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent, // Remove shadow color
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        '     로그아웃',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SvgPicture.asset('assets/icons/logout.svg'),
                  ],
                ),
                _buildDivider(),
              ],
            )
          ],
        ),
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
            backgroundColor: Colors.white, // Dialog의 배경색을 흰색으로 설정

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
                          if (text2 == '로그아웃') {
                            Navigator.pop(context);
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.remove('uid');
                              prefs.setString('token', 'false');
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          } else {
                            Navigator.pop(context);
                          }
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

    const url = 'http://10.30.97.246:3000/auth/profile/:uid';

    final Map<String, String> data = {
      'uid': uid ?? '',
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['message'] == 'User checking success') {
        print(responseData['userData']);
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

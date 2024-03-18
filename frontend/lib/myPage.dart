import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

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
      appBar: AppBar( // AppBar를 사용하여 중앙에 마이페이지 div 배치
        title: Center(
          child: Text('마이페이지'),
        ),
        actions: [ // 종모양 아이콘은 따로 배치
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AlertPage()),
              );
              // Implement your action here
            },
            icon: Padding(
    padding: EdgeInsets.only(right: 40), // 오른쪽 마진 추가
    child: SvgPicture.asset(
      'assets/icons/bell.svg', // 종 모양 이모티콘 SVG 파일
      width: 24, // 아이콘의 너비 조정
      height: 24, // 아이콘의 높이 조정
    ),
             ) // 종모양 버튼 아이콘
          ),
        ],
      ),
      body: SingleChildScrollView( // SingleChildScrollView로 감싸서 스크롤 가능하도록
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 이용안내, 문의하기, 로그아웃 버튼을 좌측으로 정렬
          children: [
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: getImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10), // 이름 div의 top margin 추가
                      child: Text(
                        '정일형',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '캡스톤',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // 글씨 크기 조정
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
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
              ],
            ),
            SizedBox(height: 10), // 이름 div와 학번 div 사이에 간격 추가
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '학번: 20195303',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20), // '이용안내, 문의하기, 로그아웃' 버튼과 회색원 간격 추가
            _buildButton('이용안내', () {}),
            _buildDivider(),
            _buildButton('문의하기', () {}),
            _buildDivider(),
            _buildButton('로그아웃', () {}),
          ],
        ),
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
            label: '예약내역',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/mypageB.svg'),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }

  // 버튼을 생성하는 함수
  Widget _buildButton(String label, VoidCallback onPressed) {
    return Container( // 버튼을 Container로 감싸서 margin 설정
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
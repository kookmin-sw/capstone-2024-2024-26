import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notice.dart';
import 'loading.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  bool isLoading = false;
  String userId = '';

  @override
  void initState() {
    super.initState();
    // 현재 날짜와 시간을 'yyyy-MM-dd HH:mm' 형식으로 설정
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> sendContent() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid')!;

    final Map<String, String> data = {
      'userId': userId,
      'date': dateController.text.toString(),
      'title': titleController.text.toString(),
      'content': contentController.text.toString(),
    };

    const url = 'http://3.35.96.145:3000/inquiry/';

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    if (response.statusCode == 200) {
    } else {
      print('전송 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '문의하기',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyNotice()),
                );
              },
              icon: SvgPicture.asset('assets/icons/notice_none.svg'),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 70),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                    labelText: '날짜 및 시간',
                    icon: Icon(Icons.calendar_today, color: Color(0xFF004F9E)),
                    enabledBorder: OutlineInputBorder(
                      // 비활성 테두리 색상
                      borderSide: BorderSide(color: Color(0xFF004F9E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // 포커스 시 테두리 색상
                      borderSide: BorderSide(color: Color(0XFF004F9E)),
                    )),
                readOnly: true,
                cursorColor: Colors.black, // 커서 색깔 변경
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText: '제목',
                    counterStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.title, color: Color(0xFF004F9E)),
                    labelStyle: TextStyle(color: Colors.black), // 레이블 색상 변경
                    focusColor: Color(0xFF004F9E),
                    prefixIconColor: Color(0xFF004F9E),
                    enabledBorder: OutlineInputBorder(
                      // 비활성 테두리 색상
                      borderSide: BorderSide(color: Color(0xFF004F9E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // 포커스 시 테두리 색상
                      borderSide: BorderSide(color: Color(0XFF004F9E)),
                    )),
                cursorColor: Colors.black, // 커서 색깔 변경
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                    labelText: '내용',
                    counterStyle: TextStyle(color: Colors.black),
                    icon: Icon(
                      Icons.message,
                      color: Color(0XFF004F9E),
                    ),
                    labelStyle: TextStyle(color: Colors.black), // 레이블 색상 변경
                    enabledBorder: OutlineInputBorder(
                      // 비활성 테두리 색상
                      borderSide: BorderSide(color: Color(0xFF004F9E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // 포커스 시 테두리 색상
                      borderSide: BorderSide(color: Color(0XFF004F9E)),
                    )),
                cursorColor: Colors.black, // 커서 색깔 변경
                maxLines: 10,
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  await sendContent();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('문의 내역이 전송되었습니다.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004F9E),
                  minimumSize: const Size(265.75, 39.46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                ),
                child: Text(
                  '내용 전송',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

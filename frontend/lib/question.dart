import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'notice.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 현재 날짜와 시간을 'yyyy-MM-dd HH:mm' 형식으로 설정
    dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
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
          icon: SvgPicture.asset('assets/icons/back.svg', color: Colors.black),
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
            ),
            SizedBox(height: 20),
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
            ),
            SizedBox(height: 20),
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
              maxLines: 10,
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                // await loginUser(context);
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

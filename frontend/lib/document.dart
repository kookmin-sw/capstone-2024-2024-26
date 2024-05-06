import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'loading.dart';
import 'complete.dart';
import 'reservation_details.dart';
import 'myPage.dart';
import 'congestion.dart';
import 'package:intl/intl.dart';

class FormPage extends StatefulWidget {
  final DateTime selectedDate;
  final int startTime;
  final int endTime;
  final String roomName;
  const FormPage({
    Key? key,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.roomName,
  }) : super(key: key);
  @override
  _FormPageState createState() => _FormPageState(
      selectedDate: selectedDate,
      startTime: startTime,
      endTime: endTime,
      roomName: roomName);
}

class _FormPageState extends State<FormPage> {
  DateTime selectedDate;
  int startTime = 0;
  int endTime = 0;
  String roomName = '';
  _FormPageState({
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.roomName,
  });

  void initState() {
    super.initState();
    _checkUidStatus();
  }

  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    const url = 'http://localhost:3000/auth/profile/:uid';

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
      print(responseData);
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

  void _addParticipant() {
    setState(() {
      participants.add(Participant());
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      if (participants.length > 1) {
        participants.removeAt(index);
      }
    });
  }

  final _formKey = GlobalKey<FormState>();
  List<Participant> participants = [];
  String gubun = '';
  String date = '';
  String department = '';
  String studentId = '';
  String name = '';
  String contact = '';
  String email = '';

  final TextEditingController _purposeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '사용 신청서 작성',
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                width: 353,
                padding: const EdgeInsets.all(20), // 예약 정보 텍스트를 감싸는 패딩 추가
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 0.50, color: Color(0xFFE3E3E3)),
                    borderRadius: BorderRadius.circular(4),
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

                child: Column(
                  children: [
                    Text(
                      '강의실 사용 신청서',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          '구분',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 43,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.44,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            '${widget.roomName}',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '사용 일시',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.43,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            textAlign: TextAlign.left,
                            '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일 ${widget.startTime}:00 ~ ${widget.endTime}:00',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '사용 목적',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        buildInputField('', controller: _purposeController),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '신청자(책임자)',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
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
                        Text(
                          '소속',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 43,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.43,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            '소프트웨어융합대학',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '학번',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 43,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.43,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            '20191621',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '성명',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 43,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.43,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            '안수현',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '연락처',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 33,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.43,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            '01053829399',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '이메일',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 33,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 243.43,
                          height: 28.97,
                          decoration: ShapeDecoration(
                            color: Color(0XFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: Text(
                            'saker123@kookmin.com',
                            style: TextStyle(
                              color: Color(0XFF686868),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '강의실 대여 명단',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
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
                        Text(
                          '본인은 강의실 대여에 있어서 신청서에 명시된 허가조건을 철저히 준수할 것과 \n대여목적 및 허가조건 이외의 행위로 인하여 발생하는 제반 사고에 대하여 \n모든 책임을 질 것은 물론 이에 대한 학교의 어떠한 조치에도\n이의 없이 따를 것을 서약합니다.',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 9,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          return ParticipantEntry(
                            index: index,
                            key: ValueKey(participants[index]),
                            participant: participants[index],
                            onRemoved: () => _removeParticipant(index),
                          );
                        },
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _addParticipant,
                          child: Text(
                            "인원 추가 +",
                            style: TextStyle(
                              color: Color(0xFF838383),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        currentIndex: 0, // Adjust the index according to your need
        onTap: (index) {
          switch (index) {
            case 0:
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

  Widget buildInputField(String labelText,
      {TextEditingController? controller}) {
    return Container(
      width: 243.44,
      height: 28.97,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.50, color: Color(0xFFEAEAEA)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: TextField(
        cursorWidth: 1.0, // 줄어든 커서의 두께
        cursorHeight: 14,
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 5, bottom: 12),
          hintText: labelText,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEAEAEA)),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEAEAEA)),
          ),
        ),
      ),
    );
  }
}

class Participant {
  String name = '';
  String department = '';
  String studentId = '';
}

class ParticipantEntry extends StatefulWidget {
  final int index;
  final Participant participant;
  final VoidCallback onRemoved;

  const ParticipantEntry(
      {Key? key,
      required this.index,
      required this.participant,
      required this.onRemoved})
      : super(key: key);

  @override
  _ParticipantEntryState createState() => _ParticipantEntryState();
}

class _ParticipantEntryState extends State<ParticipantEntry> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.participant.name;
    _departmentController.text = widget.participant.department;
    _studentIdController.text = widget.participant.studentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text('인원 ${widget.index + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF004F9E))),
              const Spacer(),
              TextButton(
                child: const Text(
                  '삭제',
                  style: TextStyle(
                    color: Color(0xFF767676),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    height: 0.30,
                  ),
                ),
                onPressed: widget.onRemoved,
              ),
            ],
          ),
          Row(
            children: [
              Text('성명', style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
              const SizedBox(width: 43),
              buildInputField(
                '',
                controller: _nameController,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('소속', style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
              const SizedBox(width: 43),
              buildInputField(
                '',
                controller: _departmentController,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('학번', style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
              const SizedBox(width: 43),
              buildInputField(
                '',
                controller: _studentIdController,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInputField(String labelText,
      {TextEditingController? controller}) {
    return Container(
      width: 243.44,
      height: 28.97,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.50, color: Color(0xFFEAEAEA)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: TextField(
        cursorWidth: 1.0, // 줄어든 커서의 두께
        cursorHeight: 14,
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 5, bottom: 12),
          hintText: labelText,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEAEAEA)),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEAEAEA)),
          ),
        ),
      ),
    );
  }
}

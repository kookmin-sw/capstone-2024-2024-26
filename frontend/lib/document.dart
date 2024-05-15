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
import 'package:signature/signature.dart';
import 'dart:typed_data'; // 서명을 이미지 데이터로 변환하기 위해 필요
import 'complete_cf.dart';

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
  bool isLoading = false;
  DateTime selectedDate;
  int startTime = 0;
  int endTime = 0;
  String roomName = '';
  String gubun = '';
  String date = '';
  String faculty = '';
  String studentId = '';
  String name = '';
  String contact = '';
  String email = '';
  final SignatureController main_controller = SignatureController(
    penStrokeWidth: 2, // 펜 두께
    penColor: Colors.black, // 펜 색상
  );
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2, // 펜 두께
    penColor: Colors.black, // 펜 색상
  );
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

  Future<void> Reservation(BuildContext context, String room_name) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    final signatureBytes = await main_controller.toPngBytes();
    String base64Signature = base64Encode(signatureBytes!);

    const url = 'http://172.16.101.160:3000/reserveroom/';
    final Map<String, String> data = {
      'userId': uid!,
      'roomName': roomName,
      'date':
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day}',
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'usingPurpose': _purposeController.text,
      'studentId': studentId,
      'participants': json.encode(participants.map((p) => p.toJson()).toList()),
      'numberOfPeople': (participants.length + 1).toString(),
      'signature': base64Signature,
    };

    debugPrint('$data');
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      isLoading = false; // 요청 완료 시 로딩 숨김
    });

    debugPrint('${response.statusCode}');

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['message'] ==
          'Reservation Conference created successfully') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Complete_cf(
                    roomName: roomName,
                    selectedDate: selectedDate,
                    startTime: startTime,
                    endTime: endTime,
                  )), // 서버 함수호출
        );
      } else {
        setState(() {});
      }
    } else {
      setState(() {});
    }
  }

  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    const url = 'http://172.16.101.160:3000/auth/profile/:uid';

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
        setState(() {
          name = responseData['userData']['name'];
          faculty = responseData['userData']['faculty'];
          studentId = responseData['userData']['studentId'];
          contact = responseData['userData']['phone'];
          email = responseData['userData']['email'];
        });
      } else {}
    } else {
      setState(() {
        String errorMessage = ''; // Define the variable errorMessage
        errorMessage = '아이디와 비밀번호를 확인해주세요';
      });
    }
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
            backgroundColor: Colors.white,

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
                  SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      child: Text(text2,
                          style: const TextStyle(
                            color: Color(0XFF004F9E),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  void _addParticipant() {
    setState(() {
      participants.add(Participant(
          name: '', department: '', studentId: '', p_signature: Uint8List(0)));
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      if (participants.length > 1) {
        participants.removeAt(index);
      }
    });
  }

  void dipose() {
    _controller.dispose();
    main_controller.dispose();
    super.dispose();
  }

  void _showmainSignaturePad(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Dialog 배경을 투명하게 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Container(
            width: 359.39,
            height: 200.41,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 359.39,
                  height: 120.41,
                  child: Signature(
                    controller: main_controller,
                    backgroundColor: Color(0XFFFFFFFF),
                  ),
                ),
                Container(
                  height: 1,
                  width: 350,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text(
                          '지우기',
                          style: TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          main_controller.clear();
                        },
                      ),
                      SizedBox(width: 35),
                      Container(
                        height: 34.74,
                        width: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      SizedBox(width: 35),
                      TextButton(
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            color: Color(0xFF004F9E),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final signature = await main_controller.toPngBytes();
                          if (signature != null && signature.isNotEmpty) {
                            Navigator.of(context).pop(signature);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('서명이 저장되었습니다.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // 사용자에게 서명이 비어 있음을 알립니다.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('서명이 비어 있습니다. 서명을 완료해주세요.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  List<Participant> participants = [];

  final TextEditingController _purposeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen();
    } else {
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
            icon:
                SvgPicture.asset('assets/icons/back.svg', color: Colors.black),
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
                      side: const BorderSide(
                          width: 0.50, color: Color(0xFFE3E3E3)),
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
                          buildInputField2('', controller: _purposeController),
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
                              faculty,
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
                              studentId,
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
                              name,
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
                              contact,
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
                              email,
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
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          height: 20,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('서약서',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Center(
                          child: Text(
                            '* 신청자는 학생증(신분증)을 필히 지참하여 당직근무자가 확인을 위하여 학생증\n 제시를 요구할 시 이에 응하여야 하며, 당직근무자의 지시에 순응하여야 한다.\n* 화재 및 안전사고 예방에 주의해야 하며 전열기 및 위험물질의 사용을 금합니다.\n* 강의실 사용 목적 이외의 행위(취사 및 음주)를 금합니다.\n* 강의실 사용 중에 비품 및 기자재의 파손 및 망실에 대한 책임은 \n[교내 물품 관리 규정] 제14조에 의거합니다.\n* 강의실 내에 설치된 비품 및 기자재 보존과 청결을 유지할 것을 약속합니다.\n* 강의실 사용 시 음식물 반입을 금지합니다.\n* 대여 가능한 기간은 최장 5일입니다(주말 제외).',
                            style: TextStyle(fontSize: 9, fontFamily: 'Inter'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                            child: Text('위와 같이 강의실/세미나실을 사용하고자 합니다.',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold))),
                        SizedBox(
                          height: 5,
                        ),
                        Center(
                          child: Text(
                              '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Inter',
                              )),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Aligns children to the right
                          children: [
                            Text('대표자',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () =>
                                  _showmainSignaturePad(context), // 함수 참조
                              child: Container(
                                  width: 189.95,
                                  height: 55.13,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 0.50,
                                          color: Color(0xFFEAEAEA)),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '서명',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC6C6C6)),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_purposeController.text.isEmpty) {
                              // 사용 목적 필드가 비어있는 경우 경고 다이얼로그 표시
                              FlutterDialog('사용 목적을 입력해주세요.', '확인');
                            } else if (main_controller.isEmpty) {
                              FlutterDialog('대표자 서명을 입력해주세요.', '확인');
                            } else if (participants.isEmpty) {
                              FlutterDialog('참여자 정보를 입력해주세요.', '확인');
                            } else if (participants.any((participant) =>
                                participant.name.isEmpty ||
                                participant.department.isEmpty ||
                                participant.studentId.isEmpty ||
                                participant.p_signature.isEmpty)) {
                              FlutterDialog('모든 참가자 정보를 입력해주세요.', '확인');
                            } else {
                              // 사용 목적이 제대로 입력된 경우 예약 진행
                              Reservation(context, widget.roomName);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004F9E),
                            minimumSize: const Size(314.75, 41.46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3)),
                          ),
                          child: const Text(
                            '사용 신청서 제출하기 ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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

Widget buildInputField2(String labelText, {TextEditingController? controller}) {
  return Container(
    width: 243.44,
    height: 50.97,
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

class Participant {
  String name = '';
  String department = '';
  String studentId = '';
  Uint8List p_signature = Uint8List(0);

  Participant(
      {this.name = '',
      this.department = '',
      this.studentId = '',
      required this.p_signature});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'department': department,
      'studentId': studentId,
      'p_signature': base64Encode(p_signature),
    };
  }
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
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2, // 펜 두께
    penColor: Colors.black, // 펜 색상
  );

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.participant.name;
    _departmentController.text = widget.participant.department;
    _studentIdController.text = widget.participant.studentId;

    _controller.addListener(_updateSignature);
    _nameController.addListener(_updateName);
    _departmentController.addListener(_updateDepartment);
    _studentIdController.addListener(_updateStudentId);
  }

  void _updateName() {
    widget.participant.name = _nameController.text;
  }

  Future<void> _updateSignature() async {
    widget.participant.p_signature = (await _controller.toPngBytes())!;
  }

  void _updateDepartment() {
    widget.participant.department = _departmentController.text;
  }

  void _updateStudentId() {
    widget.participant.studentId = _studentIdController.text;
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateName);
    _departmentController.removeListener(_updateDepartment);
    _studentIdController.removeListener(_updateStudentId);
    _controller.removeListener(_updateSignature);
    _controller.dispose();
    _nameController.dispose();

    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void saveParticipantData() async {
    // 입력된 데이터를 Participant 객체에 저장
    widget.participant.name = _nameController.text;
    widget.participant.department = _departmentController.text;
    widget.participant.studentId = _studentIdController.text;
    widget.participant.p_signature = (await _controller.toPngBytes())!;
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
          SizedBox(height: 10),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Aligns children to the right
            children: [
              Text('서명', style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () => _showSignaturePad(context), // 함수 참조
                child: Container(
                    width: 92.21,
                    height: 37.87,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0.50, color: Color(0xFFEAEAEA)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '서명',
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC6C6C6)),
                    )),
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

  void _showSignaturePad(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Dialog 배경을 투명하게 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Container(
            width: 359.39,
            height: 200.41,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 359.39,
                  height: 120.41,
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Color(0XFFFFFFFF),
                  ),
                ),
                Container(
                  height: 1,
                  width: 350,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text(
                          '지우기',
                          style: TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _controller.clear();
                        },
                      ),
                      SizedBox(width: 35),
                      Container(
                        height: 34.74,
                        width: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      SizedBox(width: 35),
                      TextButton(
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            color: Color(0xFF004F9E),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final signature = await _controller.toPngBytes();
                          if (signature != null && signature.isNotEmpty) {
                            widget.participant.p_signature = signature;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('서명이 저장되었습니다.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

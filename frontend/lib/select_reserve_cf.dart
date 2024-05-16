import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'loading.dart';
import 'complete.dart';
import 'reservation_details.dart';
import 'myPage.dart';
import 'congestion.dart';
import 'document.dart';
import 'notice.dart';

class Select_reserve_cf extends StatefulWidget {
  final String roomName;

  const Select_reserve_cf({
    Key? key,
    required this.roomName,
  }) : super(key: key);

  @override
  State<Select_reserve_cf> createState() => _select_cf(roomName: roomName);
}

class _select_cf extends State<Select_reserve_cf> {
  final Widget emptyDataWidget = Container(
    width: 50,
    // Customize your empty data representation
  );
  bool isTimeSelected = false; // 시간 선택 여부를 추적하는 변수
  Map<String, dynamic> reservations = {}; // 예약 정보를 불러와서 비활성화할거임 .
  List<bool> isButtonPressedList =
      List.generate(16, (index) => false); // 버튼마다 눌림 여부를 저장하는 리스트

  List<bool> updatedIsButtonPressedList =
      List.generate(16, (index) => false); //시간 차있는지 확인

  @override
  void initState() {
    super.initState();
    _checkUidStatus();
    sendSelectedDateToServer(selectedDate);
  }

  _checkReservation(
    Map<String, dynamic> reservations,
  ) async {
    updatedIsButtonPressedList = List.generate(16, (index) => false); // 초기화

    if (reservations['reservations'].isEmpty) {
      return;
    }

    for (var reservation in reservations['reservations']) {
      String timeRange = reservation['timeRange'];
      int startHour = int.parse(timeRange.split('-')[0]);
      int endHour = int.parse(timeRange.split('-')[1]);

      int startIndex = startHour - 9; // 시간이 9시부터 시작하므로
      int endIndex = endHour - 9; // 예약 종료 시간도 계산

      for (int i = startIndex; i < endIndex; i++) {
        // 예약 시작부터 종료 전까지 마감 처리
        updatedIsButtonPressedList[i] = true;
      }
    }
  }

  // 선택된 날짜를 서버로 전송하는 함수
  sendSelectedDateToServer(DateTime selectedDate) async {
    try {
      const url = 'http://172.30.1.11:3000/reserveroom/selectdate';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      uid = prefs.getString('uid');
      final Map<String, String> data = {
        'userId': uid!,
        'roomName': roomName,
        'date':
            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day}',
      };

      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      // 서버 응답 처리
      if (response.statusCode == 200) {
        // 서버 응답이 성공적인 경우

        reservations = json.decode(response.body);

        _checkReservation(reservations);
      } else {
        // 서버 에러 처리
        print('Failed to send date. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending date: $e');
    }
  }

  String roomName;
  _select_cf({
    required this.roomName,
  });

  final double intervalWidth = 50.0;

  final ExpansionTileController controller = ExpansionTileController();

  String startTime = ''; //server
  String endTime = '';
  String room_name = ''; //server
  int table_number = 0; // server

  int total_table = 1;
  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수
  String? uid = '';
  int setting = 0;
  int table_setting = 0;
  int st = 0;
  int ed = 0;

  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
  }

  void showErrorAndReset(int index, String message) {
    setState(() {
      isButtonPressedList[index] = false; // 버튼 비활성화
      setting -= 1; // 설정된 시간 감소
    });
    FlutterDialog(message, '확인'); // 에러 메시지 다이얼로그 표시
  }

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '강의실 대여',
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: [
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // 예약 정보를 왼쪽 상단에 정렬
                    children: [
                      Text(
                        roomName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // Divider와 예약 시간 사이에 간격 추가
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 20,
                      ),

                      TableCalendar(
                        // 이슈 등록 해야함 멈춤 증상 , locale: 'ko_KR',

                        rowHeight: 40,
                        daysOfWeekHeight: 30,

                        // 최상단 일월화수목 ...
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),

                        // 캘린더에서 날짜가 선택될때 이벤트
                        onDaySelected: (selectedDay, focusedDay) async {
                          // 서버로부터 데이터를 받아온 후에 상태를 업데이트
                          await sendSelectedDateToServer(
                              selectedDay); // 선택된 날짜를 서버로 전송하고 응답을 기다립니다.
                          setState(() {
                            isTimeSelected = false;
                            selectedDate = selectedDay; // 날짜 상태 업데이트
                            isButtonPressedList =
                                List.generate(16, (index) => false);

                            setting = 0;
                          });
                        },
                        // 특정 날짜가 선택된 날짜와 동일한지 여부 판단
                        selectedDayPredicate: (date) {
                          return isSameDay(selectedDate, date);
                        },
                        calendarFormat: CalendarFormat.month, //2주 출력가능

                        focusedDay: DateTime.now(),
                        firstDay: DateTime.now(),
                        lastDay: DateTime(DateTime.now().year + 5),
                        // 헤더 부분 2024.3
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          titleTextFormatter: (date, locale) =>
                              '${date.year}.${date.month}',
                          formatButtonVisible: false,
                          leftChevronIcon:
                              (SvgPicture.asset('assets/icons/che_left.svg')),
                          leftChevronMargin: const EdgeInsets.only(left: 80),
                          rightChevronIcon:
                              (SvgPicture.asset('assets/icons/che_right.svg')),
                          rightChevronMargin: const EdgeInsets.only(right: 80),
                          headerMargin: const EdgeInsets.all(0),
                          titleTextStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.black,
                          ),
                        ),
                        //몸통부분 달력 .
                        calendarStyle: const CalendarStyle(
                          isTodayHighlighted: true,
                          todayTextStyle: TextStyle(
                            color: Color(0xFF004F9E),
                            fontFamily: 'Inter',
                            fontSize: 10,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          selectedTextStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          selectedDecoration: BoxDecoration(
                              color: Color(0xFF004F9E),
                              shape: BoxShape.rectangle),
                          outsideDaysVisible: false,
                          defaultTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Inter',
                          ),
                          weekendTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 20,
                      ),

                      const Row(
                        children: [
                          SizedBox(height: 40),
                          Text(
                            '시간을 선택하세요',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 20),
                          Text(
                            '** 연속적인 필요 시간만 선택하세요. \n   무분별한 사용한 반려될 수 있습니다.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFA3A3A3),
                            ),
                          ),
                        ],
                      ),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            16,
                            (index) {
                              int hour = index + 9;

                              if (updatedIsButtonPressedList[index] == true) {
                                return Padding(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // 텍스트를 왼쪽으로 정렬
                                    children: [
                                      Text(
                                        '$hour시',
                                        style: const TextStyle(
                                          color: Color(0xFFA3A3A3),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0XFFD9D9D9),
                                              minimumSize: const Size(50, 30),
                                              shape:
                                                  const RoundedRectangleBorder(),
                                              elevation: 0.2, // 그림자 제거
                                            ),
                                            child: const Text('마감',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          ),
                                          Container(
                                            height: 25.74,
                                            width: 1,
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // 텍스트를 왼쪽으로 정렬
                                    children: [
                                      Text(
                                        '$hour시',
                                        style: const TextStyle(
                                          color: Color(0xFFA3A3A3),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isButtonPressedList[index] =
                                                    !isButtonPressedList[index];
                                                isTimeSelected =
                                                    isButtonPressedList.any(
                                                        (element) => element);
                                                ;
                                                if (isButtonPressedList[
                                                        index] ==
                                                    true) {
                                                  setting += 1;
                                                  if (setting == 1) {
                                                    st = hour;
                                                    ed = hour + 1;
                                                  } else if (setting > 1) {
                                                    ed = ed + 1;
                                                  }
                                                } else {
                                                  setting -= 1;
                                                  if (setting == 0) {
                                                    st = 0;

                                                    ed = 0;
                                                  } else if (setting <= 1) {
                                                    st = ed;
                                                    ed = st;
                                                  }
                                                }

                                                // 시간 선택의 연속성을 확인
                                                if (!validateContinuousSelection(
                                                    isButtonPressedList)) {
                                                  showErrorAndReset(
                                                      index, '연속적인 시간을 선택하세요.');
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isButtonPressedList[
                                                      index]
                                                  ? const Color(0XFF004F9E)
                                                  : const Color(
                                                      0xFFF8F8F8), // 해당 버튼의 눌림 여부에 따라 색을 변경
                                              minimumSize: const Size(50, 30),
                                              shape:
                                                  const RoundedRectangleBorder(),
                                              elevation: 0.2, // 그림자 제거
                                            ),
                                            child: const Text('  '),
                                          ),
                                          Container(
                                            height: 25.74,
                                            width: 1,
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const SizedBox(width: 10),
                          SvgPicture.asset('assets/icons/dead.svg'),
                          const Text(
                            '마감     ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SvgPicture.asset('assets/icons/possible.svg',
                              color: const Color(0XFF004F9E)),
                          const Text(
                            '  예약 가능',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 20,
                      ),

                      ElevatedButton(
                        onPressed: isTimeSelected
                            ? () {
                                // 연속된 시간이 선택된 경우에만 신청서 작성 페이지로 이동
                                if (validateContinuousSelection(
                                    isButtonPressedList)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FormPage(
                                        roomName: roomName,
                                        selectedDate: selectedDate,
                                        startTime: st,
                                        endTime: ed,
                                      ),
                                    ),
                                  );
                                } else {
                                  showErrorAndReset(-1, '연속적인 시간을 선택하세요.');
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTimeSelected
                              ? Color(0xFF004F9E)
                              : Color(0xFFD9D9D9),
                          minimumSize: const Size(314.87, 41.97),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        child: const Text(
                          '사용 신청서 작성하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 하단 바
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

  // onDaySelected 함수 추가
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(selectedDate, selectedDay)) {
      // 현재 선택된 날짜와 새로 선택된 날짜가 다를 경우
      setState(() {
        selectedDate = selectedDay;
        // 시간 선택 배열 초기화
        isButtonPressedList = List.generate(16, (index) => false);
        isTimeSelected = false; // 시간 선택 여부 업데이트
        setting = 0; // 선택된 시간의 개수 초기화
        st = 0; // 시작 시간 초기화
        ed = 0; // 종료 시간 초기화
      });
    }
  }

  // 선택된 시간의 연속성 검사 함수
  bool validateContinuousSelection(List<bool> selections) {
    int lastSelectedIndex = -1;
    for (int i = 0; i < selections.length; i++) {
      if (selections[i]) {
        if (lastSelectedIndex != -1 && (i - lastSelectedIndex > 1)) {
          return false; // 비연속적인 인덱스 찾기
        }
        lastSelectedIndex = i;
      }
    }
    return true;
  }

// Function to check if a date is before today
  bool isDateBeforeToday(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }
}

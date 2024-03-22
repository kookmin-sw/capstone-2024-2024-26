import 'main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in.dart';
import 'package:http/http.dart' as http;

class Select_reserve extends StatefulWidget {
  @override
  _select createState() => _select();
}

class _select extends State<Select_reserve> {
  final Widget emptyDataWidget = Container(
    width: 50,
    // Customize your empty data representation
  );
  void initState() {
    super.initState();
    _checkUidStatus();
  }

  final double intervalWidth = 50.0;
  final PageController _pageController = PageController();
  final ExpansionTileController controller = ExpansionTileController();
  int _currentIndex = 0;
  String time = '09:00 ~ 22:00'; //server
  String people = '12'; //server
  String room_name = '미래관 601호'; //server
  String table_number = '2'; // server
  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수
  String? uid = '';

  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    print(uid);
  }

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '동아리방 대여',
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
                    side: BorderSide(width: 0.50, color: Color(0xFFE3E3E3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  shadows: [
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
                    const Text(
                      '예약 정보',
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
                      onDaySelected: onDaySelected,
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
                        leftChevronMargin: const EdgeInsets.only(left: 84),
                        rightChevronIcon:
                            (SvgPicture.asset('assets/icons/che_right.svg')),
                        rightChevronMargin: const EdgeInsets.only(right: 84),
                        headerMargin: EdgeInsets.all(0),
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
                        todayTextStyle: const TextStyle(
                          color: Color(0xFF3694A8),
                          fontFamily: 'Inter',
                          fontSize: 10,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        selectedDecoration: BoxDecoration(
                            color: const Color(0xFF3694A8),
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
                    Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),

                    Row(
                      children: [
                        SizedBox(height: 40),
                        const Text(
                          '시간을 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '일일 최대 2시간 이용가능',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(height: 40),
                        Text(
                          '인원을 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '인원',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '최대 ?명까지 예약 가능합니다.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFA3A3A3),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),

                    Row(
                      children: [
                        SizedBox(height: 40),
                        Text(
                          '좌석을 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        await Reservation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3694A8),
                        minimumSize: const Size(314.87, 41.97),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      child: Text(
                        '예약하기',
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10), // 모든 방향으로 바텀 패딩.
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/lent.svg'),
              label: '공간 대여',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/reserved.svg'),
              label: '예약 내역',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/mypage.svg'),
              label: '마이페이지',
            ),
          ],
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          selectedItemColor: Colors.black,
        ),
      ),
    );
  }

  Future<void> Reservation(BuildContext context) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });

    const url = 'http://localhost:3000/reserveclub/';
    final Map<String, String> data = {
      'userId': uid!,
      'roomId': room_name,
      'date': selectedDate.toString(),
      'startTime': time,
      'endTime': time,
      'numberOfPeople': people,
      'tableNumber': table_number,
    };

    debugPrint('${data}');
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
      if (responseData['message'] == 'Reservation club created successfully') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        setState(() {
          //errorMessage = '아이디와 비밀번호를 확인해주세요';
        });
      }
    } else {
      setState(() {
        //errorMessage = '아이디와 비밀번호를 확인해주세요';
      });
    }
  }

  // onDaySelected 함수 추가
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
  }

// Function to check if a date is before today
  bool isDateBeforeToday(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }
}

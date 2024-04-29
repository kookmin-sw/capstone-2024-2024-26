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

class Select_reserve extends StatefulWidget {
  const Select_reserve({super.key});

  @override
  _select createState() => _select();
}

class _select extends State<Select_reserve> {
  final Widget emptyDataWidget = Container(
    width: 50,
    // Customize your empty data representation
  );
  @override
  void initState() {
    super.initState();
    _checkUidStatus();
  }

  final double intervalWidth = 50.0;

  final ExpansionTileController controller = ExpansionTileController();

  String startTime = ''; //server
  String endTime = '';
  String room_name = '미래관 601호'; //server
  int table_number = 0; // server

  int total_table = 1;
  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수
  String? uid = '';
  int setting = 0;
  int count = 0;
  int count2 = 0;
  int find = 0;

  List<bool> isButtonPressedList =
      List.generate(16, (index) => false); // 버튼마다 눌림 여부를 저장하는 리스트
  List<bool> isButtonPressedTable =
      List.generate(16, (index) => false); // 버튼마다 눌림 여부를 저장하는 리스트

  List<Offset> circlePositions = [
    const Offset(10, 0),
    const Offset(40, 0),
    const Offset(70, 0),
    const Offset(10, 30),
    const Offset(40, 30),
    const Offset(70, 30),
  ]; // 의자 위치
  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
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
            '공간대여',
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
                        calendarFormat: CalendarFormat.twoWeeks, //2주 출력가능

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
                          SizedBox(width: 10),
                          Text(
                            '일일 최대 2시간 이용가능',
                            style: TextStyle(
                              fontSize: 12,
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
                              return Padding(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start, // 텍스트를 왼쪽으로 정렬
                                  children: [
                                    Text(
                                      '$hour시',
                                      style: const TextStyle(
                                        color: Color(0xFFA3A3A3),
                                        fontSize: 10,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isButtonPressedList[index] =
                                              !isButtonPressedList[index];
                                          if (isButtonPressedList[index] ==
                                              true) {
                                            setting += 1;
                                            if (setting > 3) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        '2시간 이상 예약할 수 없습니다'),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            isButtonPressedList[
                                                                index] = false;
                                                            setting -= 1;
                                                          });
                                                        },
                                                        child: const Text('확인'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            setting -= 1;
                                          }

                                          print(setting);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isButtonPressedList[
                                                index]
                                            ? const Color(0XFF004F9E)
                                            : const Color(
                                                0xFFF8F8F8), // 해당 버튼의 눌림 여부에 따라 색을 변경
                                        minimumSize: const Size(50, 30),
                                        shape: const RoundedRectangleBorder(),
                                        elevation: 0.2, // 그림자 제거
                                      ),
                                      child: const Text('  '),
                                    ),
                                  ],
                                ),
                              );
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

                      const Row(
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

                      Stack(
                        children: [
                          for (var position in circlePositions)
                            Positioned(
                              top: position.dy,
                              left: position.dx,
                              child: SvgPicture.asset(
                                'assets/icons/circle.svg',
                              ),
                            ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                1,
                                (index) {
                                  return Padding(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              isButtonPressedTable[index] =
                                                  !isButtonPressedTable[index];
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isButtonPressedTable[index]
                                                    ? const Color(0xFF004F9E)
                                                    : const Color(0xFFEAEAEA),
                                            minimumSize:
                                                const Size(98.655, 37.61),
                                            elevation: 0.0,
                                          ),
                                          child: Text(
                                            'T ${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          //의자 위치 6명이면 6개
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
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
                          SvgPicture.asset(
                            'assets/icons/possible.svg',
                            color: const Color(0XFF004F9E),
                          ),
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

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () async {
                          await Reservation(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004F9E),
                          minimumSize: const Size(314.87, 41.97),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        child: const Text(
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

  Future<void> Reservation(BuildContext context) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });

    if (startTime != '' && endTime != '') {
      for (int i = 0; i < isButtonPressedList.length; i++) {
        if (isButtonPressedList[i] == true) {
          startTime = (i + 9).toString();
          endTime = (i + 10).toString();
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('시간을 선택해주세요'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }

    // 테이블 번호선택 알고리즘
    for (int i = 0; i < isButtonPressedTable.length; i++) {
      if (isButtonPressedTable[i] == true) {
        table_number = i + 1;
      }
    }

    const url = 'http://localhost:3000/reserveclub/';
    final Map<String, String> data = {
      'userId': uid!,
      'roomId': room_name,
      'date': selectedDate.toString(),
      'startTime': startTime,
      'endTime': endTime,
      'tableNumber': table_number.toString(),
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
      if (responseData['message'] == 'Reservation club created successfully') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Complete()),
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

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
import 'notice.dart';

class Select_reserve extends StatefulWidget {
  final String roomName;
  final String time;
  Select_reserve({Key? key, required this.roomName, required this.time})
      : super(key: key);

  @override
  State<Select_reserve> createState() =>
      _select(roomName: roomName, time: time);
}

class _select extends State<Select_reserve> {
  bool isFirstVisit = true; // 사용자가 첫 방문인지 여부
  bool isAgreed = false; // 사용자가 안내사항에 동의했는지 여부
  String time;
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> reservations = {}; // 예약 정보를 불러와서 비활성화할거임 .

  String roomName;
  _select({
    required this.roomName,
    required this.time,
  });

  final double intervalWidth = 50.0;

  final ExpansionTileController controller = ExpansionTileController();
  bool timeSelected = false; // 시간 선택 상태를 추적하는 변수
  int timeIndex = 0; // 선택된 시간대의 인덱스를 저장하는 변수
  String startTime = ''; //server
  String endTime = '';
  String room_name = '';
  int table_number = 0; // server

  Map<int, List<bool>> timeTableStatus = {};

  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수
  String? uid = '';
  int setting = 0;

  int st = 0;
  int ed = 0;

  List<bool> isButtonPressedList =
      List.generate(16, (index) => false); // 버튼마다 눌림 여부를 저장하는 리스트

  List<bool> isButtonPressedTable =
      List.generate(16, (index) => false); // 실제 테이블 수에 맞게 크기 조정 필요

  List<bool> updatedIsButtonPressedList =
      List.generate(16, (index) => false); //시간 차있는지 확인
  bool timeslot = false;

// tablelist는 서버에서 받아온 데이터로 대체
  List<dynamic> tableList = [
    {
      'available': '4',
      'table_name': 'T1',
      'table_status': 'true',
    },
    {
      'available': '6',
      'table_name': 'T2',
      'table_status': 'true',
    },
    {
      'available': '6',
      'table_name': 'T3',
      'table_status': 'true',
    },
    {
      'available': '6',
      'table_name': 'T4',
      'table_status': 'true',
    },
  ];

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final Widget emptyDataWidget = Container(
    width: 50,
    // Customize your empty data representation
  );
  @override
  void initState() {
    super.initState();

    _checkUidStatus();

    _checkFirstVisit();

    selectedDate = DateTime.now();
    sendSelectedDateToServer(selectedDate);
  }

  _checkUidStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
  }

  _checkReservation(
    Map<String, dynamic> reservations,
  ) async {
    if (reservations['reservations'].isEmpty) {
      updatedIsButtonPressedList =
          List.generate(16, (index) => false); //시간 차있는지 확인

      List<bool> updatedIsButtonPressedTable =
          List.generate(tableList.length, (index) => false); // 테이블 차있는지 확인
      for (int i = 0; i < updatedIsButtonPressedList.length; i++) {
        timeTableStatus[i] = List.generate(tableList.length, (index) => false);
      }
      return;
    }
    for (var reservation in reservations['reservations']) {
      updatedIsButtonPressedList =
          List.generate(16, (index) => false); //시간 차있는지 확인

      List<bool> updatedIsButtonPressedTable = List.generate(
          reservation['tables'].length, (index) => false); // 테이블 차있는지 확인
      String timeRange = reservation['timeRange'];
      int startHour = int.parse(timeRange.split('-')[0]);

      int startIndex = startHour - 9;

      List<dynamic> tables = reservation['tables'];

      for (int i = 0; i < updatedIsButtonPressedList.length; i++) {
        timeTableStatus[i] =
            List.generate(reservation['tables'].length, (index) => false);
      }
      for (int i = 0; i < tables.length; i++) {
        var table = tables[i];
        // 테이블이 예약되어 있으면 해당 테이블 버튼을 비활성화
        if (table['T${i + 1}'] == true) {
          updatedIsButtonPressedTable[i] = true;
        }
      }

      if (updatedIsButtonPressedTable.every((element) => element == true)) {
        updatedIsButtonPressedList[startIndex] = true;
      }

      if (updatedIsButtonPressedList.every((element) => element == true)) {
        timeslot = true;
      }

      timeTableStatus[startIndex] = updatedIsButtonPressedTable;
    }
  }

  // 사용자의 첫 방문 여부를 확인
  _checkFirstVisit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstVisit = prefs.getBool('isFirstVisit') ?? true;
    if (isFirstVisit == false) {
      // 첫 방문인 경우 안내사항을 보여줍니다.
      _showGuidanceDialog();
      await prefs.setBool('isFirstVisit', false); // 첫 방문 상태 업데이트
    }
  }

  // 선택된 날짜를 서버로 전송하는 함수
  sendSelectedDateToServer(DateTime selectedDate) async {
    try {
      const url = 'http://localhost:3000/reserveclub/selectdate';
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

  void _showGuidanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isChecked = false; // 체크박스 상태 관리용 변수
        return Dialog(
          backgroundColor: Colors.transparent, // Dialog 배경을 투명하게 설정
          child: Container(
            width: 1500, // 다이얼로그의 너비 설정
            height: 1500, // 다이얼로그의 높이 설정
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
                    "안내사항",
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
                      "\n이 공유공간은 학생들이 그룹 스터디, 토론,\n 조별과제 등의 팀 단위 학업 수행을 위해 마련된 \n공간으로 팀 단위 당 하루 최대 4시간을 예약하여 \n이용하실 수 있습니다. \n\nThis shared space is designed for students to \nconduct teamwork such as group studies, \ndiscussions, and group assignments. \nEach team can reserve up to 4 hours per day.\n\n주의사항\n\n1.예약 신청 후 사전 취소 없이 2회 공간 미이용 시 \n시설 이용 페널티가 발생합니다.\n2.페널티 2회 이상 부여 받을 시에는 60일의 \n시설 이용이 정지됩니다. \n3.예약 신청 시간 이후 10분 내에 입실하지 않을 시에 \n예약 취소되며 다음 대기자에게 자동 예약됩니다.\n 4.음식물 취식 가능 여부 등은 해당 공간의 \n규칙에 따라 상이합니다.\n 5.사용 후 정리 정돈 및 사진 촬영은 필수이며 이행하지 \n않을 시에는 페널티가 부여됩니다. \n6.정리 정돈 사진은 AI에 의해 통과 여부가 판단됩니다. \n\n\n1. If the space is not used twice without prior \ncancellation after requesting a reservation, \na facility use penalty will be incurred.\n2. If you receive a penalty more than twice,\n your use of the facility will be\n suspended for 60 days.\n3. If you do not check in within 10 minutes \nafter the reservation application time,\nyour reservation will be canceled and \nthe reservation will automatically \nbe made to the next person on the waiting list.\n4. Whether food can be eaten or not depends \non the rules of the space.\n5. Cleaning up after use and taking photos \nare required, and penalties may apply \nif you do not do so.\n6. Organized photos are judged \nby AI to pass or fail.",
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
                            selectedDate = selectedDay; // 날짜 상태 업데이트
                            isButtonPressedList =
                                List.generate(16, (index) => false);
                            isButtonPressedTable =
                                List.generate(16, (index) => false);
                            setting = 0;
                          });
                        },
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
                            '최대 연속 2시간씩 예약 가능 ',
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
                              //sendSelectedDateToServer(selectedDate);
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
                                                if (isButtonPressedList[
                                                        index] ==
                                                    true) {
                                                  setting += 1;
                                                  if (setting == 1) {
                                                    st = hour;
                                                    ed = hour + 1;
                                                  } else if (setting == 2) {
                                                    if (hour == st + 1) {
                                                      // 새로운 시간이 시작 시간 다음 시간과 일치하는지 확인
                                                      ed = hour +
                                                          1; // 조건을 만족하는 경우 종료 시간 업데이트
                                                    } else {
                                                      showErrorAndReset(index,
                                                          '예약은 연속 2시간만 가능합니다.'); // 연속된 시간이 아니면 에러 표시
                                                    }
                                                  }

                                                  if (setting > 2) {
                                                    setState(() {
                                                      isButtonPressedList[
                                                          index] = false;
                                                      setting -= 1;
                                                    });
                                                    FlutterDialog(
                                                        '예약은 최대 2시간까지 가능합니다.',
                                                        '확인');
                                                  }
                                                  timeSelected =
                                                      true; // 시간이 선택되었음을 나타냄
                                                  timeIndex =
                                                      index; // 선택된 시간대의 인덱스 저장
                                                } else {
                                                  timeSelected = false;
                                                  timeIndex = -1;
                                                  setting -= 1;
                                                  ed = 0;
                                                  if (setting == 0) {
                                                    st = 0;
                                                    ed = 0;
                                                  } else if (setting == 1) {
                                                    st = ed;
                                                    ed = st;
                                                  }
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
                      SingleChildScrollView(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // 한 줄에 3개의 좌석을 표시
                            childAspectRatio: 2 /
                                1, // 아이템의 가로 세로 비율을 조정 (가로 길이를 세로 길이의 3배로 설정)
                          ),
                          itemCount: tableList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _CustomTableWidget(
                              isButtonPressedTable: isButtonPressedTable,
                              timeSelected: timeSelected,
                              timeIndex: timeIndex,
                              timeTableStatus: timeTableStatus,
                              onTablePressed: (index) {
                                setState(() {
                                  isButtonPressedTable[index] =
                                      !isButtonPressedTable[index];
                                });
                              },
                              tableIndex: index,
                              tableList: tableList,
                            );
                          },
                        ),
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
                          await Reservation(context, roomName);
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

  Future<void> Reservation(BuildContext context, String room_name) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });
    // Initialize start and end time
    int startHour = 0;
    int endHour = 0;

    // Find selected time range
    for (int i = 0; i < isButtonPressedList.length; i++) {
      if (isButtonPressedList[i]) {
        startHour = i + 9; // Assuming index 0 corresponds to 9 AM
        break;
      }
    }

    for (int i = isButtonPressedList.length - 1; i >= 0; i--) {
      if (isButtonPressedList[i]) {
        endHour = i + 10; // Assuming index 0 corresponds to 9 AM
        break;
      }
    }

    // Check if both start and end time are selected
    if (startHour == 0 || endHour == 0) {
      FlutterDialog('시간을 선택해주세요', '확인');
      setState(() {
        isLoading = false; // 요청 완료 시 로딩 숨김
      });
      return;
    }

    // Validate time range
    if (endHour - startHour > 2) {
      FlutterDialog('예약은 최대 2시간까지 가능합니다.', '확인');
      setState(() {
        isLoading = false; // 요청 완료 시 로딩 숨김
      });
      return;
    }

    // Set start and end time strings
    startTime = '$startHour:00';
    endTime = '$endHour:00';

    // Find selected table number
    for (int i = 0; i < isButtonPressedTable.length; i++) {
      if (isButtonPressedTable[i]) {
        table_number = i + 1;

        break;
      }
    }

    if (table_number == 0) {
      FlutterDialog('좌석을 선택해주세요', '확인');
      setState(() {
        isLoading = false; // 요청 완료 시 로딩 숨김
      });
      return;
    }

    const url = 'http://localhost:3000/reserveclub/';
    final Map<String, String> data = {
      'userId': uid!,
      'roomName': roomName,
      'date':
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day}',
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

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Creating reservation club successfully') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Complete(
                    roomName: roomName,
                    selectedDate: selectedDate,
                    startTime: st,
                    endTime: ed,
                    table_number: table_number.toString(),
                  )),
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

  void showErrorAndReset(int index, String message) {
    setState(() {
      isButtonPressedList[index] = false; // 버튼 비활성화
      setting -= 1; // 설정된 시간 감소
    });
    FlutterDialog(message, '확인'); // 에러 메시지 다이얼로그 표시
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

class _CustomTableWidget extends StatefulWidget {
  final List<bool> isButtonPressedTable;

  final bool timeSelected;
  final int timeIndex;
  final Map<int, List<bool>> timeTableStatus;
  final int tableIndex; // 테이블의 인덱스
  final ValueSetter<int> onTablePressed;
  final List<dynamic> tableList;
  const _CustomTableWidget({
    Key? key,
    required this.isButtonPressedTable,
    required this.timeSelected,
    required this.timeIndex,
    required this.timeTableStatus,
    required this.onTablePressed,
    required this.tableIndex,
    required this.tableList,
  }) : super(key: key);

  @override
  _CustomTableWidgetState createState() => _CustomTableWidgetState();
}

class _CustomTableWidgetState extends State<_CustomTableWidget> {
  @override
  Widget build(BuildContext context) {
    // 컨테이너의 너비를 조정하여 버튼이 더 많이 보이도록 설정
    double containerWidth = 300.0; // 이 값을 조정하여 전체 너비를 설정
    double buttonWidth = 49.655; // 버튼 너비 설정

    return Container(
      width: containerWidth, // 컨테이너의 너비를 설정
      height: 50.61,
      child: Row(
        children: [
          // 버튼을 Row 내에 포함
          ElevatedButton(
            onPressed: widget.timeSelected &&
                    !(widget.timeTableStatus[widget.timeIndex]
                            ?[widget.tableIndex] ??
                        false)
                ? () {
                    widget.onTablePressed(widget.tableIndex);
                  }
                : null, // timeSelected가 true이고 해당 테이블이 예약되지 않았을 때만 활성화
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isButtonPressedTable[widget.tableIndex]
                  ? const Color(0xFF004F9E)
                  : const Color(0xFFEAEAEA),
              minimumSize: Size(buttonWidth, 37.61), // 버튼 크기 설정

              elevation: 0.0,
            ),
            child: Text(
              widget.timeTableStatus[widget.timeIndex]?[widget.tableIndex] ??
                      false
                  ? '마감'
                  : 'T${widget.tableIndex + 1}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 추가 버튼을 여기에 배치할 수 있습니다.
        ],
      ),
    );
  }
}

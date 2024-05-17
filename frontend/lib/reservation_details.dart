import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'myPage.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'return.dart';
import 'congestion.dart';
import 'notice.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'loading.dart';

class Details extends StatefulWidget {
  const Details({
    Key? key,
  }) : super(key: key);

  @override
  _Details createState() => _Details();
}

class _Details extends State<Details> with WidgetsBindingObserver {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 14)); // 현재로부터 14일 후
  DateTime previousDate =
      DateTime.now().subtract(Duration(days: 14)); // 현재로부터 14일 전
  List<dynamic> reservations = [];
  List<dynamic> done_reservations = [];
  List<dynamic> classroomReservations = [];
  List<dynamic> classroomDoneReservations = [];
  bool is_tap = false;
  String userId = '';
  bool isLoading = false;
  Map<int, bool> isLentMap = {};
  Map<int, String> remainingTimeMap = {};
  Map<int, Timer?> timersMap = {};
  Map<int, DateTime> endTimesMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchReservations(startDate, endDate).then((_) {
      loadTimerStates();
    });
    doneReservations(previousDate, startDate);

    fetchClassroomReservations(startDate, endDate).then((_) {
      loadTimerStates();
    });
    doneClassroomReservations(previousDate, startDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> loadTimerStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < reservations.length; i++) {
      bool? isLent = prefs.getBool('isLent_$i');
      String? remainingTime = prefs.getString('remainingTime_$i');
      String? endTimeStr = prefs.getString('endTime_$i');

      if (isLent != null &&
          isLent &&
          remainingTime != null &&
          endTimeStr != null) {
        DateTime endTime = DateTime.parse(endTimeStr);
        DateTime now = DateTime.now();
        if (now.isBefore(endTime)) {
          int secondsRemaining = endTime.difference(now).inSeconds;
          startEntryTimer(i, now, endTime, remainingSeconds: secondsRemaining);
          setState(() {
            isLentMap[i] = isLent;
            remainingTimeMap[i] = remainingTime;
          });
        } else {
          // 만료된 경우 상태 초기화
          setState(() {
            isLentMap[i] = false;
            remainingTimeMap[i] = '00:00:00';
          });
        }
      }
    }
  }

  Future<void> saveTimerState(int index) async {
    if (isLentMap[index] != null &&
        remainingTimeMap[index] != null &&
        endTimesMap[index] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLent_$index', isLentMap[index]!);
      await prefs.setString('remainingTime_$index', remainingTimeMap[index]!);
      await prefs.setString(
          'endTime_$index', endTimesMap[index]!.toIso8601String());
    }
  }

  Future<void> fetchReservations(DateTime start, DateTime end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    setState(() {
      isLoading = true;
    });
    String formattedStartDate =
        "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    final url =
        'http://10.30.97.246:3000/reserveclub/reservationPrevious/$userId/$formattedStartDate/$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            reservations = mergeConsecutiveReservations(data['reservations']);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      throw Exception('Failed to load reservations: $e');
    }
  }

  Future<void> fetchClassroomReservations(DateTime start, DateTime end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    setState(() {
      isLoading = true;
    });

    String formattedStartDate =
        "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    final url =
        'http://10.30.97.246:3000/reserveroom/reservationPrevious/$userId/$formattedStartDate/$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            classroomReservations =
                mergeConsecutiveReservations(data['previousReservation']);

            isLoading = false;
          });
          print(classroomReservations);
        }
      } else {
        throw Exception('Failed to load classroom reservations');
      }
    } catch (e) {
      throw Exception('Failed to load classroom reservations: $e');
    }
  }

  List<dynamic> mergeConsecutiveReservations(List<dynamic> reservations) {
    if (reservations.isEmpty) return [];
    reservations.sort((a, b) {
      if (a['date'] == b['date']) {
        return a['startTime'].compareTo(b['startTime']);
      }
      return a['date'].compareTo(b['date']);
    });
    List<dynamic> merged = [];

    var current = reservations.first;

    for (var i = 1; i < reservations.length; i++) {
      var next = reservations[i];
      if (current['date'] == next['date'] &&
          current['endTime'] == next['startTime']) {
        current['endTime'] = next['endTime'];
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }

  Future<void> doneReservations(DateTime start, DateTime end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    setState(() {
      isLoading = true;
    });
    String formattedStartDate =
        "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    final url =
        'http://10.30.97.246:3000/reserveclub/reservationDone/$userId/$formattedStartDate/$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            done_reservations =
                mergeConsecutiveReservations(data['reservations']);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      throw Exception('Failed to load reservations: $e');
    }
  }

  Future<void> doneClassroomReservations(DateTime start, DateTime end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    setState(() {
      isLoading = true;
    });
    String formattedStartDate =
        "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    final url =
        'http://10.30.97.246:3000/reserveroom/reservationsDone/$userId/$formattedStartDate/$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            classroomDoneReservations =
                mergeConsecutiveReservations(data['doneReservation']);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load classroom reservations');
      }
    } catch (e) {
      throw Exception('Failed to load classroom reservations: $e');
    }
  }

  final DateTime selectedDate = DateTime.now();
  final int startTime = 12;
  final int endTime = 15;
  final String roomName = '';
  final String table_number = '';

  // tableData 내부에서 true 값을 가진 키 찾기
  String getKeyWithTrueValue(Map<String, dynamic>? tableData) {
    if (tableData != null) {
      for (String key in tableData.keys) {
        if (tableData[key] == true) {
          return key; // true 값을 가진 첫 번째 키를 반환
        }
      }
    }
    return 'N/A'; // true 값을 가진 키가 없을 경우 또는 tableData가 null일 경우
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '예약 내역',
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
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
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
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        is_tap = false;
                        fetchReservations(startDate, endDate);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 15, // Set the button text size
                        fontWeight:
                            FontWeight.bold, // Set the button text weight
                        color: Color(0XFF004F9E),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                            width: 0.50,
                            color: is_tap
                                ? Color(0xFFD6D6D6)
                                : const Color(0xFF004F9E)),
                      ),
                      minimumSize:
                          const Size(195.7, 50), // Set the button minimum size
                      backgroundColor:
                          is_tap ? Colors.white : const Color(0X0C004F9E),

                      elevation: 0, // Set the elevation for the button shadow
                      shadowColor: Colors.white.withOpacity(
                          0.5), // Set the color of the button shadow
                    ),
                    child: Text('공유공간 예약내역',
                        style: TextStyle(
                            color: is_tap
                                ? const Color(0XFF7C7C7C)
                                : const Color(0xFF004F9E))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        is_tap = true;
                        fetchClassroomReservations(startDate, endDate);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 15, // Set the button text size
                        fontWeight:
                            FontWeight.bold, // Set the button text weight
                        color: Color(0XFF004F9E),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                            width: 0.50,
                            color: is_tap
                                ? const Color(0xFF004F9E)
                                : Color(0xFFD6D6D6)),
                      ),
                      minimumSize:
                          const Size(195.7, 50), // Set the button minimum size
                      backgroundColor:
                          is_tap ? const Color(0X0C004F9E) : Colors.white,

                      elevation: 0, // Set the elevation for the button shadow
                      shadowColor: Colors.white.withOpacity(
                          0.5), // Set the color of the button shadow
                    ),
                    child: Text('강의실 예약내역',
                        style: TextStyle(
                            color: is_tap
                                ? const Color(0xFF004F9E)
                                : const Color(0XFF7C7C7C))),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    '이용 예정',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF004F9E),
                    ),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              (is_tap ? classroomReservations : reservations).isNotEmpty
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: is_tap
                          ? classroomReservations.length
                          : reservations.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> reservation = is_tap
                            ? classroomReservations[index]
                            : reservations[index];
                        bool? boolAgree =
                            is_tap ? reservation['boolAgree'] as bool? : null;
                        return Column(
                          children: [
                            _buildReservationItem(
                                reservation['roomName'],
                                reservation['date'],
                                reservation['startTime'],
                                reservation['endTime'],
                                getKeyWithTrueValue(reservation['tableData']),
                                index,
                                boolAgree),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        '예약 내역이 없습니다.',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
              const SizedBox(height: 20),
              const DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: 350,
                lineThickness: 0.5,
                dashLength: 3.0,
                dashColor: Colors.grey,
                dashRadius: 0.0,
                dashGapLength: 6.0,
                dashGapColor: Colors.transparent,
                dashGapRadius: 0.0,
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    '이용 내역',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              if ((is_tap ? classroomDoneReservations : done_reservations)
                  .isNotEmpty)
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: is_tap
                      ? classroomDoneReservations.length
                      : done_reservations.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> done_reservation = is_tap
                        ? classroomDoneReservations[index]
                        : done_reservations[index];
                    return Column(
                      children: [
                        _buildUsageHistoryItem(
                          done_reservation['roomName'],
                          done_reservation['date'],
                          done_reservation['startTime'],
                          done_reservation['endTime'],
                          getKeyWithTrueValue(done_reservation['tableData']),
                        ),
                      ],
                    );
                  },
                )
              else
                const Center(
                  child: Text(
                    '완료된 예약 내역이 없습니다.',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 2,
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
              icon: SvgPicture.asset('assets/icons/lent_off.svg'),
              label: '공간대여',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/congestion_off.svg'),
              label: '혼잡도',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/reserved_on.svg'),
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

  Widget _buildReservationItem(
    String roomName,
    String date,
    String startTime,
    String endTime,
    String table_number,
    int index,
    bool? boolAgree,
  ) {
    bool isLent = isLentMap[index] ?? false;
    String remainingTime = remainingTimeMap[index] ?? '00:00:00';

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/Subtract2.png'),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '[ $roomName ]',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 100),
                const Text(
                  '강의실',
                  style: TextStyle(
                    color: Color(0XFF484848),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 20.87,
                  width: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                const SizedBox(width: 10),
                Text(
                  isLent
                      ? '이용 중'
                      : (boolAgree == null
                          ? '이용 예정'
                          : (boolAgree ? '이용 예정' : '승인 대기')),
                  style: const TextStyle(
                    color: Color(0XFF484848),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            const DottedLine(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              lineLength: 300,
              lineThickness: 0.5,
              dashLength: 3.0,
              dashColor: Colors.grey,
              dashRadius: 0.0,
              dashGapLength: 6.0,
              dashGapColor: Colors.transparent,
              dashGapRadius: 0.0,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '날짜  $date',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF004F9E),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.21,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$startTime:00~$endTime:00  |  좌석 $table_number',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.21,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  DateTime startDateTime =
                      DateTime.parse('$date $startTime:00');
                  DateTime currentTime = DateTime.now();
                  Duration difference = startDateTime.difference(currentTime);
                  bool canEnter =
                      difference.inMinutes <= 10 && difference.isNegative;

                  if (canEnter) {
                    isLent
                        ? FlutterDialog("반납하시겠습니까?", "반납하기", index)
                        : EnterDialog("입장하시겠습니까?", "입장하기", index);
                  } else if (boolAgree == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('승인 대기 중인 예약입니다.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('예약시간 10분 전부터 입장 가능합니다.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004F9E),
                  minimumSize: const Size(330.11, 57.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15, // 기본 폰트 크기
                      fontFamily: 'Inter', // 폰트 스타일
                      fontWeight: FontWeight.w700, // 폰트 두께
                      color: Colors.white, // 기본 색상
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: isLent ? '        반납하기 \n' : '입장하기',
                      ),
                      if (isLent)
                        TextSpan(
                          text: '남은 이용시간 $remainingTime', // 반납까지 남은 시간 변수
                          style: const TextStyle(
                            fontSize: 12, // 남은 시간 폰트 크기
                            fontWeight: FontWeight.w500, // 남은 시간 폰트 두께
                          ),
                        ),
                    ],
                  ),
                )),
            const SizedBox(height: 15),
            Container(
              height: 1,
              width: 350,
              color: Colors.grey.withOpacity(0.2),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => cancelReservation(index),
                    child: const Text(
                      '예약 취소',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageHistoryItem(String roomName, String date, String startTime,
      String endTime, String table_number) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/Subtract3.png'),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '[ $roomName ]',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 100),
                const Text(
                  '공유공간',
                  style: TextStyle(
                    color: Color(0XFF484848),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 20.87,
                  width: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                const SizedBox(width: 10),
                const Text(
                  '이용 완료',
                  style: TextStyle(
                    color: Color(0XFF484848),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const DottedLine(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              lineLength: 300,
              lineThickness: 0.5,
              dashLength: 3.0,
              dashColor: Colors.grey,
              dashRadius: 0.0,
              dashGapLength: 6.0,
              dashGapColor: Colors.transparent,
              dashGapRadius: 0.0,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '날짜  $date',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF004F9E),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.21,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$startTime:00~$endTime:00  |  좌석 $table_number',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.21,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 45),
          ],
        ),
      ],
    );
  }

  Future<void> FlutterDialog(String text, String text2, int index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 359.39,
            height: 45.41,
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
                  height: 1,
                  width: 350,
                  color: Colors.grey.withOpacity(0.2),
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
                    const SizedBox(width: 35),
                    Container(
                      height: 34.74,
                      width: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    const SizedBox(width: 50),
                    TextButton(
                      child: Text(text2,
                          style: const TextStyle(
                            color: Color(0XFF004F9E),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () async {
                        Navigator.pop(context);

                        if (text2 == '반납하기') {
                          setState(() {
                            isLentMap[index] = false;
                            timersMap[index]?.cancel();
                            reservations.removeAt(index);
                          });
                          saveTimerState(index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Return()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> EnterDialog(String text, String text2, int index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 359.39,
            height: 45.41,
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
                  height: 1,
                  width: 350,
                  color: Colors.grey.withOpacity(0.2),
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
                    const SizedBox(width: 35),
                    Container(
                      height: 34.74,
                      width: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    const SizedBox(width: 50),
                    TextButton(
                      child: Text(text2,
                          style: const TextStyle(
                            color: Color(0XFF004F9E),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () async {
                        Navigator.pop(context);

                        setState(() {
                          isLentMap[index] = true;
                          DateTime endDateTime = DateTime.parse(
                              reservations[index]['date'] +
                                  ' ' +
                                  reservations[index]['endTime'] +
                                  ':00');
                          DateTime now = DateTime.now();
                          endTimesMap[index] = endDateTime;
                          int secondsRemaining =
                              endDateTime.difference(now).inSeconds;
                          startEntryTimer(index, now, endDateTime,
                              remainingSeconds: secondsRemaining);
                        });
                        saveTimerState(index);
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> cancelReservation(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 359.39,
            height: 45.41,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "예약을 취소하시겠습니까?",
                  style: TextStyle(
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
                  height: 1,
                  width: 350,
                  color: Colors.grey.withOpacity(0.2),
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
                    const SizedBox(width: 35),
                    Container(
                      height: 34.74,
                      width: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    const SizedBox(width: 50),
                    TextButton(
                      child: const Text("예약 취소",
                          style: TextStyle(
                            color: Color(0XFF004F9E),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () async {
                        final url = is_tap
                            ? 'http://10.30.97.246:3000/reserveroom/delete'
                            : 'http://10.30.97.246:3000/reserveclub/delete';
                        final response = await http.post(
                          Uri.parse(url),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'userId': userId,
                            'roomName': is_tap
                                ? classroomReservations[index]['roomName']
                                : reservations[index]['roomName'],
                            'date': is_tap
                                ? classroomReservations[index]['date']
                                : reservations[index]['date'],
                            'startTime': is_tap
                                ? classroomReservations[index]['startTime']
                                : reservations[index]['startTime'],
                            'endTime': is_tap
                                ? classroomReservations[index]['endTime']
                                : reservations[index]['endTime'],
                            'tableNumber': is_tap
                                ? 'N/A'
                                : getKeyWithTrueValue(
                                    reservations[index]['tableData']),
                          }),
                        );

                        if (response.statusCode == 200) {
                          if (mounted) {
                            setState(() {
                              if (is_tap) {
                                classroomReservations.removeAt(index);
                              } else {
                                reservations.removeAt(index);
                              }
                              Navigator.pop(context);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('예약이 성공적으로 취소되었습니다 !'),
                              ),
                            );

                            // 타이머 상태 제거
                            isLentMap.remove(index);
                            remainingTimeMap.remove(index);
                            timersMap[index]?.cancel();
                            timersMap.remove(index);
                            endTimesMap.remove(index);
                          }
                        } else {
                          // 서버 오류 처리
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('예약 취소에 실패했습니다.'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timersMap.forEach((key, timer) => timer?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 타이머 재시작
      timersMap.keys.forEach((index) {
        if (isLentMap[index] == true && endTimesMap[index] != null) {
          DateTime endDateTime = endTimesMap[index]!;
          DateTime now = DateTime.now();
          if (now.isBefore(endDateTime)) {
            int secondsRemaining = endDateTime.difference(now).inSeconds;
            startEntryTimer(index, now, endDateTime,
                remainingSeconds: secondsRemaining);
          } else {
            // 예약 시간이 이미 종료된 경우
            if (mounted) {
              setState(() {
                isLentMap[index] = false;
                remainingTimeMap[index] = '00:00:00';
              });
            }
          }
        }
      });
    }
  }

  void startEntryTimer(int index, DateTime startDateTime, DateTime endDateTime,
      {int? remainingSeconds}) {
    int seconds =
        remainingSeconds ?? endDateTime.difference(startDateTime).inSeconds;

    timersMap[index]?.cancel(); // 기존 타이머가 있으면 취소

    timersMap[index] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (seconds > 0) {
          seconds--;
          int hours = seconds ~/ 3600;
          int minutes = (seconds % 3600) ~/ 60;
          int second = seconds % 60;
          remainingTimeMap[index] =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
          saveTimerState(index);
        } else {
          timer.cancel();
          isLentMap[index] = false;
          remainingTimeMap[index] = '00:00:00';
        }
      });
    });
  }
}

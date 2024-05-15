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
  bool is_tap = false;
  String userId = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchReservations(userId, startDate, endDate);
    done_Reservations(userId, previousDate, startDate);
  }

  Future<List<dynamic>> fetchReservations(
      String userId, DateTime start, DateTime end) async {
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
        'http://192.168.200.103:3000/reserveclub/reservationclubs/$userId/$formattedStartDate/$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 서버로부터 정상적인 응답을 받았을 때
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          isLoading = false;
          reservations = data['reservations'];
          List<dynamic> mergedReservations =
              mergeConsecutiveReservations(reservations);
          reservations = mergedReservations;
        });

        return data['reservations'];
      } else {
        // 서버로부터 오류 응답을 받았을 때
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      throw Exception('Failed to load reservations: $e');
    }
  }

  List<dynamic> mergeConsecutiveReservations(List<dynamic> reservations) {
    if (reservations.isEmpty) return [];

    reservations.sort((a, b) => a['startTime'].compareTo(b['startTime']));
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

  Future<List<dynamic>> done_Reservations(
      String userId, DateTime start, DateTime end) async {
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
        'http://192.168.200.103:3000/reserveclub/reservationclubs/$userId/$formattedStartDate/$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 서버로부터 정상적인 응답을 받았을 때
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          isLoading = false;
          done_reservations = data['reservations'];
          List<dynamic> mergedReservations =
              mergeConsecutiveReservations(done_reservations);
          done_reservations = mergedReservations;
        });

        return data['reservations'];
      } else {
        // 서버로부터 오류 응답을 받았을 때
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      throw Exception('Failed to load reservations: $e');
    }
  }

  final DateTime selectedDate = DateTime.now();
  final int startTime = 12;
  final int endTime = 15;
  final String roomName = '';
  final String table_number = '';

  // tableData 내부에서 true 값을 가진 키 찾기
  String getKeyWithTrueValue(Map<String, dynamic> tableData) {
    for (String key in tableData.keys) {
      if (tableData[key] == true) {
        return key; // true 값을 가진 첫 번째 키를 반환
      }
    }
    return 'No key with true value found'; // true 값을 가진 키가 없을 경우
  }

  bool isLent = false;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            is_tap = !is_tap;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
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
                              Size(193.7, 50), // Set the button minimum size
                          backgroundColor:
                              is_tap ? Colors.white : Color(0X0C004F9E),

                          elevation:
                              0, // Set the elevation for the button shadow
                          shadowColor: Colors.white.withOpacity(
                              0.5), // Set the color of the button shadow
                        ),
                        child: Text('공유공간 예약내역',
                            style: TextStyle(
                                color: is_tap
                                    ? Color(0XFF7C7C7C)
                                    : Color(0xFF004F9E))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            is_tap = !is_tap;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
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
                              Size(193.7, 50), // Set the button minimum size
                          backgroundColor:
                              is_tap ? Color(0X0C004F9E) : Colors.white,

                          elevation:
                              0, // Set the elevation for the button shadow
                          shadowColor: Colors.white.withOpacity(
                              0.5), // Set the color of the button shadow
                        ),
                        child: Text('강의실 예약내역',
                            style: TextStyle(
                                color: is_tap
                                    ? Color(0xFF004F9E)
                                    : Color(0XFF7C7C7C))),
                      ),
                    ],
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
              reservations.isNotEmpty
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        if (reservations[index]['tableData']['status'] ==
                            'previous') {
                          Map<String, dynamic> reservation =
                              reservations[index];
                          return Column(
                            children: [
                              _buildReservationItem(
                                reservation['roomName'],
                                reservation['date'],
                                reservation['startTime'],
                                reservation['endTime'],
                                getKeyWithTrueValue(reservation['tableData']),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink(); // 아무 것도 표시하지 않음
                        }
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
              if (done_reservations.isNotEmpty &&
                  done_reservations
                      .any((res) => res['tableData']['status'] == 'done'))
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: done_reservations.length,
                  itemBuilder: (context, index) {
                    if (done_reservations[index]['tableData']['status'] ==
                        'done') {
                      // 이용 완료인 예약만 표시
                      Map<String, dynamic> done_reservation =
                          done_reservations[index];
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
                    } else {
                      return const SizedBox.shrink(); // 아무 것도 표시하지 않음
                    }
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

  Widget _buildReservationItem(String roomName, String date, String startTime,
      String endTime, String table_number) {
    bool showEntryButton =
        now.isAfter(startDate.subtract(Duration(minutes: 10))) &&
            now.isBefore(endDate.add(Duration(minutes: 10)));

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
                  '[ ${roomName} ]',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 100),
                Text(
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
                Text(
                  isLent ? '이용 중' : '이용 예정',
                  style: TextStyle(
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
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '날짜  ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${startTime}:00~${endTime}:00  |  좌석 ${table_number}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                  isLent
                      ? FlutterDialog("반납하시겠습니까?", "반납하기")
                      : EnterDialog("입장하시겠습니까?", "입장하기");
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
                          text: '남은 이용시간 $_remainingTime', // 남은 시간 변수
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
                    onPressed: () => FlutterDialog("예약을 취소하시겠습니까 ?", "예약 취소"),
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
                  '[ ${roomName} ]',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '날짜  ${date}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${startTime}:00~${endTime}:00  |  좌석 ${table_number}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

  void FlutterDialog(String text, String text2) {
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
                      onPressed: () {
                        Navigator.pop(context);

                        if (text2 == '반납하기') {
                          setState(() {
                            isLent = false;
                            _timer?.cancel();
                          });

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

  void EnterDialog(String text, String text2) {
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
                      onPressed: () {
                        Navigator.pop(context);

                        isLent = true;

                        startEntryTimer();
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

  Timer? _timer;
  String _remainingTime = '00:00:00'; // 시, 분, 초 형태로 초기화
  DateTime? _endTime;
  DateTime now = DateTime.now();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 타이머 재시작
      startEntryTimer();
    }
  }

  void startEntryTimer() {
    DateTime endTime =
        DateTime.now().add(Duration(hours: 2)); // 예약 종료 시간, 예시로 2시간 후 설정
    int seconds = endTime.difference(DateTime.now()).inSeconds;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
          int hours = seconds ~/ 3600;
          int minutes = (seconds % 3600) ~/ 60;
          int second = seconds % 60;
          _remainingTime =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
        } else {
          timer.cancel();
        }
      });
    });
  }
}

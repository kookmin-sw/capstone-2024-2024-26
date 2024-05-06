import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'myPage.dart';
import 'package:dotted_line/dotted_line.dart';
import 'return.dart';
import 'congestion.dart';
import 'notice.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  _Details createState() => _Details();
}

class _Details extends State<Details> {
  bool isLent = false;

  @override
  Widget build(BuildContext context) {
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
            _buildReservationItem(),
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
            _buildUsageHistoryItem(),
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

  Widget _buildReservationItem() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/Subtract2.png'),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 13),
            const Text(
              '[ 미래관 610호 ]',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
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
            const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '날짜  2024.3.19(화)',
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
            const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '오후  12:00~15:00  |  좌석 T1',
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
              onPressed: () => FlutterDialog("입장하시겠습니까?", "입장하기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004F9E),
                minimumSize: const Size(330.11, 57.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                isLent ? '반납하기' : '입장하기',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
                    onPressed: () => FlutterDialog("예약을 변경하시겠습니까 ?", "변경하기"),
                    child: const Text(
                      '예약 변경',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 60),
                  Container(
                    height: 34.74,
                    width: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(width: 60),
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

  Widget _buildUsageHistoryItem() {
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
                const Text(
                  '[ 미래관 610호 ]',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 110),
                Container(
                  height: 20.87,
                  width: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                const SizedBox(width: 30),
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
            const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '날짜  2024.3.19(화)',
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
            const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '오후  12:00~15:00  |  좌석 T1',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Return()),
                        );
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
}

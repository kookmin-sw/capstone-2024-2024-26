import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'settings.dart';
import 'main.dart';
import 'reservation_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'myPage.dart';
import 'notice.dart';

enum MenuType { first, second, third }

class Congestion extends StatefulWidget {
  const Congestion({super.key});

  @override
  _CongestionState createState() => _CongestionState();
}

class _CongestionState extends State<Congestion> {
  List<Map<String, String>> congestionData = [];

  final Map<String, int> congestionWeights = {
    '매우 혼잡': 4,
    '혼잡': 3,
    '보통': 2,
    '여유': 1
  };

  final _values = [
    '전체',
    '북악관',
    '미래관',
    '공학관',
    '복지관',
    '예술관',
    '과학관',
    '본부관',
    '법학관',
    '조형관'
  ];
  final _sortValues = ['혼잡도 높은 순', '혼잡도 낮은 순'];

  String _selectedValue = '';
  String _selectedSortValue = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedValue = _values[0];
      _selectedSortValue = _sortValues[0];
    });
    fetchData();
  }

  Future<void> fetchData() async {
    const url = 'http://3.39.102.188:5000/api/info';
    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          print(jsonDecode(response.body)); // 받는 데이터
          congestionData = (jsonDecode(response.body)); // 고쳐야할 부분
        });
      } else {
        print('Failed to load congestion data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<Map<String, dynamic>> get filteredAndSortedData {
    List<Map<String, String>> filteredData = congestionData
        .where((data) =>
            _selectedValue == '전체' ||
            data['location_detail']!.contains(_selectedValue))
        .toList();

    List<Map<String, dynamic>> sorted = List.from(filteredData);
    sorted.sort((a, b) {
      return _selectedSortValue == '혼잡도 높은 순'
          ? congestionWeights[b['congestion']]!
              .compareTo(congestionWeights[a['congestion']]!)
          : congestionWeights[a['congestion']]!
              .compareTo(congestionWeights[b['congestion']]!);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '혼잡도',
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
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(right: 270),
              child: Text(
                '실시간 혼잡도',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
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
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: SvgPicture.asset(
                    'assets/icons/congestion_bar.svg',
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Container(
                  width: 83,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedValue,
                      items: _values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                    )),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 120,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedSortValue,
                      items: _sortValues
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                    )),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSortValue = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredAndSortedData.length,
              itemBuilder: (context, index) {
                final data = filteredAndSortedData[index];

                return Column(
                  children: [
                    SizedBox(height: 10),
                    _CustomScrollViewWidget(
                      location: data['location']!,
                      location_detail: data['location_detail']!,
                      congestion: data['congestion']!,
                      color: data['color']!,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
              break;
            case 1:
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
            icon: SvgPicture.asset('assets/icons/lent_off.svg'),
            label: '공간대여',
          ),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/congestion.svg'),
              label: '혼잡도'),
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
        selectedItemColor: const Color.fromARGB(255, 158, 136, 136),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.grey,
      indent: 20,
      endIndent: 20,
    );
  }
}

class _CustomScrollViewWidget extends StatelessWidget {
  final String location;
  final String location_detail;
  final String congestion;
  final String color;

  const _CustomScrollViewWidget({
    Key? key,
    required this.location,
    required this.location_detail,
    required this.congestion,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: 361.65,
          height: 54,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.50, color: Color(0xFFFFFFFF)),
              borderRadius: BorderRadius.circular(2),
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
          child: Row(
            children: [
              Container(
                child: Text(
                  '     ' + location,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                '|  ' + location_detail,
                style: TextStyle(
                  color: Color(0XFFADADAD),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Container(
                alignment: Alignment.center,
                width: 67,
                height: 30,
                decoration: ShapeDecoration(
                  color: Color(0x00D9D9D9),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFE3E3E3)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  congestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(int.parse(color.substring(2), radix: 16)),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'reservation_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReturnSuccess extends StatefulWidget {
  final String imagePath;
  final String roomName;
  final String table;
  final String isTap;
  final String startTime;
  final String endTime;
  final String date;
  const ReturnSuccess(
      {Key? key,
      required this.imagePath,
      required this.date,
      required this.startTime,
      required this.roomName,
      required this.table,
      required this.isTap,
      required this.endTime})
      : super(key: key);

  @override
  _ReturnSuccessState createState() => _ReturnSuccessState();
}

class _ReturnSuccessState extends State<ReturnSuccess> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _submitReturn();
  }

  Future<void> _submitReturn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('uid')!;
    String location = widget.roomName;
    String url;
    Map<String, dynamic> data;

    if (widget.isTap == '1') {
      // isTap이 true이면 클럽 API 호출
      url = 'http://13.209.184.71:3000/reserveclub/return';
      data = {
        'userId': userId,
        'roomName': widget.roomName,
        'date': widget.date,
        'startTime': widget.startTime,
        'endTime': widget.endTime,
        'tableNumber': widget.table.replaceFirst('T', ''),
      };
    } else {
      // isTap이 false이면 강의실 API 호출
      url = 'http://13.209.184.71:3000/reserveroom/return';
      data = {
        'userId': userId,
        'roomName': widget.roomName,
        'date': widget.date,
        'startTime': widget.startTime,
        'endTime': widget.endTime,
      };
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('반납 성공');
    } else {
      print('반납 실패: ${response.body}');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Details()),
              );
            },
            icon: Icon(Icons.close),
          ),
        ],
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the app bar elevation
        shadowColor: Colors.transparent, // Remove the app bar shadow
      ),
      body: isLoading
          ? LoadingScreen() // 로딩 화면 표시
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '   공간 반납이 \n완료되었습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  child: Center(
                    child: Image.file(File(widget.imagePath),
                        width: 300, height: 300, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 150),
                Text('*공간을 정돈하지 않고 반납시, 패널티가 부여될 수 있습니다',
                    style: TextStyle(
                      color: Color(0XFF676767),
                      fontSize: 12,
                    )),
              ],
            ),
    );
  }
}

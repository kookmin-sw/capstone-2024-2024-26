import 'dart:io';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'reservation_details.dart';

class ReturnSuccess extends StatefulWidget {
  final String imagePath;

  const ReturnSuccess({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ReturnSuccessState createState() => _ReturnSuccessState();
}

class _ReturnSuccessState extends State<ReturnSuccess> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 이미지 로딩이 비동기적으로 이루어지는 것을 가정하고 2초 후 로딩 완료 가정
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
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

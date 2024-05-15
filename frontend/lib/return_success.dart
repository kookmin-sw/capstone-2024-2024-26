import 'dart:io';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'reservation_details.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '공간 반납이 완료되었습니다',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.file(File(widget.imagePath),
                        width: 271, height: 218, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
    );
  }
}

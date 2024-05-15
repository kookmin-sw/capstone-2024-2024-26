import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:frontend/signup_sucess.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'settings.dart';
import 'main.dart';
import 'reservation_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'loading.dart';
import 'return_success.dart';

class Return extends StatefulWidget {
  @override
  _ReturnState createState() => _ReturnState();
}

class _ReturnState extends State<Return> {
  TakePictureScreen? _takePictureScreen;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // initState에서 카메라 초기화
  }

  Future<void> _initializeCamera() async {
    setState(() {
      isLoading = true;
    });
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      // 사용 가능한 카메라가 없는 경우에 대한 처리
      print("No available cameras found.");
      return;
    }
    final firstCamera = cameras.first;

    setState(() {
      _takePictureScreen = TakePictureScreen(camera: firstCamera);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '공간반납 촬영',
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
        body: _takePictureScreen ?? Container(), // null 체크 후 사용
      );
    }
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
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
            width: 367.47, // 다이얼로그의 너비 설정
            height: 423.77, // 다이얼로그의 높이 설정
            decoration: BoxDecoration(
                color: Colors.white, // 다이얼로그의 배경색 지정
                borderRadius: BorderRadius.circular(7) // 모서리를 직각으로 설정
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text(
                    "공간 반납 안내",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: SingleChildScrollView(
                    child: Text(
                      "반납 시, 화면에 맞춰 이용한 공간의 사진을 찍으면\n공간 반납이 완료 됩니다.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0XFF676767),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            width: 135.71,
                            height: 180.71,
                            decoration: ShapeDecoration(
                              color: Color(0xFFF4F4F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  '어질러진 공간 사진',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF676767),
                                  ),
                                ),
                                Image.asset(
                                  'assets/dirty.png',
                                  width: 120,
                                  height: 97,
                                ),
                                Icon(Icons.close) // x모양 아이콘 추가
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            width: 135.71,
                            height: 180.71,
                            decoration: ShapeDecoration(
                              color: Color(0xFFF4F4F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  '정돈된 공간 사진',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF676767),
                                  ),
                                ),
                                Image.asset(
                                  'assets/clean.png',
                                  width: 120,
                                  height: 97,
                                ),

                                Icon(
                                    Icons.radio_button_unchecked), // O모양 아이콘 추가
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    isLoading = false;
  }

  void _initializeCameraController() async {
    setState(() {
      isLoading = true;
    });
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      _showGuidanceDialog(); // 카메라 준비가 완료된 후 다이얼로그 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        Expanded(
          child: CameraPreview(_controller),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () async {
            try {
              final image = await _controller.takePicture();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayPictureScreen(imagePath: image.path),
                ),
              );
            } catch (e) {
              print("Error: $e");
            }
          },
          child:
              SvgPicture.asset('assets/icons/camera.svg', color: Colors.grey),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.help, color: Color(0XFFD9D9D9)),
                onPressed: () {
                  _showGuidanceDialog();
                },
              ),
            ),
            SizedBox(width: 30),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '반납된 사진 확인',
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
        ),
        body: Column(
          children: [
            Image.file(File(imagePath), width: 300, height: 500),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DisplayPictureScreen(imagePath: imagePath)),
                );
              },
              child: Text(
                '제출하기',
                style: TextStyle(
                  color: Color(0XFF004F9E),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Return()),
                    );
                  },
                  child: Text(
                    '다시 찍기',
                    style: TextStyle(
                      color: Color(0XFF939393),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SvgPicture.asset('assets/icons/arrow_back.svg'),
              ],
            ),
            SizedBox(height: 70),
            Text('*공간을 정돈하지 않고 반납시, 패널티가 부여될 수 있습니다',
                style: TextStyle(
                  color: Color(0XFF676767),
                  fontSize: 12,
                )),
          ],
        ));
  }
}

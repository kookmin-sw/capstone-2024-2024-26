import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'package:frontend/sign_in.dart';
import 'dart:convert';
import 'sign_up.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

bool isLoading = false;

class SignupSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '회원가입 완료',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/success.png', // Replace with your image path
              width: 150,
              height: 150,
            ),
            ElevatedButton(
              onPressed: () async {
                await loginUser(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9F9F9),
                minimumSize: const Size(265.75, 39.46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
              ),
              child: Text(
                isLoading ? '로딩 중...' : '로그인하기',
                style: TextStyle(
                  color: Color(0xFF3694A8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });

    const url = 'http://localhost:3000/auth/signin';
    final Map<String, String> data = {
      'email': "se",
      'password': "tt",
    };

    debugPrint('email:${data['email']}');

    debugPrint('${data}');
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
      if (responseData['success'] == true && responseData['token'] != null) {
        saveTokenToSharedPreferences(responseData['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF3694A8),
            margin: EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
        //로그인성공시 메인페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        setState(() {
          var errorMessage = '아이디와 비밀번호를 확인해주세요';
        });
      }
    } else {
      setState(() {
        var errorMessage = '아이디와 비밀번호를 확인해주세요';
      });
    }
  }

  void setState(Null Function() param0) {}

  void saveTokenToSharedPreferences(responseData) {}
}

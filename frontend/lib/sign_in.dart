import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_up.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isChecked = false;
  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 0.06,
                ),
              ),
              buildInputField(
                '이메일',
                controller: emailController,
              ),
              buildInputField('비밀번호',
                  isPassword: true, controller: passwordController),
              Container(
                width: double.infinity,
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    activeColor: const Color(0xFF3694A8),
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  const Text(
                    '자동 로그인',
                    style: TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  await loginUser(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3694A8),
                  minimumSize: const Size(265.75, 39.46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                ),
                child: Text(
                  isLoading ? '로딩 중...' : '로그인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.5,
                height: 60,
                indent: 30,
                endIndent: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("회원이 아니신가요?",
                      style: TextStyle(color: Color(0xFF7A7A7A))),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: const Text("회원가입",
                        style: TextStyle(color: Color(0xFF3694A8))),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveTokenToSharedPreferences(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });

    const url = 'http://10.30.119.166:3000/auth/signin';
    final Map<String, String> data = {
      'email': emailController.text,
      'password': passwordController.text,
    };

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        setState(() {
          errorMessage = '아이디와 비밀번호를 확인해주세요';
        });
      }
    } else {
      setState(() {
        errorMessage = '아이디와 비밀번호를 확인해주세요';
      });
    }
  }

  Widget buildInputField(String labelText,
      {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      obscureText: isPassword,
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF9C9C9C)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
        ),
      ),
    );
  }
}

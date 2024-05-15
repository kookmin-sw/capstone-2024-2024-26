import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/signup_sucess.dart';
import 'package:http/http.dart' as http;
import 'sign_in.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isChecked = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();
  TextEditingController facultyController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController clubController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String errorMessage = '';

  final List<String> _clubs = [
    'Wink',
    'D-Alpha',
    'KoBot',
    'Poska',
  ];
  final List<String> _faculties = [
    '소프트웨어 융합 대학',
    '창의 공과 대학',
    '조형 대학',
    '경상 대학',
  ];

  String? _selectedClub;
  String? _selectedFaculty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/back.svg', color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,

        backgroundColor: Colors.transparent, // 상단바 배경색
        foregroundColor: Colors.black, //상단바 아이콘색

        //shadowColor: Colors(), 상단바 그림자색
        bottomOpacity: 0.0,
        elevation: 0.0,
        scrolledUnderElevation: 0,

        ///
        // 그림자 없애는거 위에꺼랑 같이 쓰면 됨
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(right: 220),
                child: Text(
                  '이름',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('이름을 입력하세요', controller: nameController),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 220),
                child: Text(
                  '학번',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('학번을 입력하세요', controller: studentIdController),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 195),
                child: Text(
                  '단과대학',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildDropdownField('단과대학', _faculties, _selectedFaculty),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 220),
                child: Text(
                  '학과',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('학과를 입력하세요', controller: departmentController),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 180),
                child: Text(
                  '소속 동아리',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildDropdownField('소속 동아리', _clubs, _selectedClub),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 170),
                child: Text(
                  '이메일(아이디)',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('example@kookmin.ac.kr',
                  controller: emailController),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 195),
                child: Text(
                  '비밀번호',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('비밀번호를 입력하세요',
                  isPassword: true, controller: passwordController),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 175),
                child: Text(
                  '비밀번호 확인',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('비밀번호를 입력하세요',
                  isPassword: true, controller: confirmPasswordController),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(right: 180),
                child: Text(
                  '휴대폰 번호',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildInputField('휴대폰 번호를 입력하세요', controller: phoneController),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.only(left: 35.0), // Row 위쪽에 10 픽셀의 여백 추가
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    const Text(
                      '개인정보 이용 및 약관에 동의하시겠습니까?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.left,
                  )),
              const SizedBox(height: 10),
              Center(
                // Center widget added
                child: ElevatedButton(
                  // ElevatedButton centered
                  onPressed: () async {
                    if (validateFields()) {
                      await registerUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004F9E),
                    minimumSize: const Size(265.75, 39.46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "이미 회원이신가요?",
                    style: TextStyle(color: Color(0xFF7A7A7A)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle login action
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignIn()),
                      );
                    },
                    child: const Text("로그인",
                        style: TextStyle(color: Color(0xFF004F9E))),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String labelText,
      {bool isPassword = false, TextEditingController? controller}) {
    return Container(
      width: 265.75,
      height: 28.97,
      decoration: ShapeDecoration(
        color: const Color(0x4FECECEC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: TextField(
        obscureText: isPassword,
        controller: controller,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9C9C9C)),
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: const Color.fromARGB(255, 246, 246, 246),
        ),
      ),
    );
  }

  Widget buildDropdownField(
      String labelText, List<String> items, String? value) {
    return SizedBox(
      width: 265.75,
      height: 28.97,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: const TextStyle(
            color: Color(0xFF9C9C9C),
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 246, 246, 246),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        value: value,
        onChanged: (newValue) {
          setState(() {
            if (labelText == '소속 동아리') {
              _selectedClub = newValue;
            } else if (labelText == '단과대학') {
              _selectedFaculty = newValue;
            }
          });
        },
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool validateFields() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = '모든 필드를 입력해주세요';
      });
      return false;
    }

    if (!EmailValidator.validate(emailController.text)) {
      setState(() {
        errorMessage = '올바른 이메일 주소를 입력해주세요';
      });
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = '비밀번호와 비밀번호 확인이 일치하지 않습니다';
      });
      return false;
    }

    if (!isChecked) {
      setState(() {
        errorMessage = '약관에 동의해주세요';
      });
      return false;
    }

    return true;
  }

  Future<void> registerUser() async {
    const url = 'http://192.168.200.103:3000/auth/signup';
    final Map<String, String> data = {
      'email': emailController.text,
      'password': passwordController.text,
      'name': nameController.text,
      'studentId': studentIdController.text,
      'faculty': facultyController.text,
      'department': departmentController.text,
      'club': clubController.text,
      'phone': phoneController.text,
      'agreeForm': isChecked.toString(),
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);

      if (responseData['message'] == 'User created successfully') {
        print('회원가입 성공'); // echo check
        // 회원가입 성공 시 회원가입 완료 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupSuccess()),
        );
      } else {
        debugPrint('회원가입 실패');
      }
    } else {
      // HTTP 요청 실패
      debugPrint('회원가입 실패. Status code: ${response.statusCode}');
    }
  }
}

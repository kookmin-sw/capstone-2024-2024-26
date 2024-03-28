import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/signup_sucess.dart';
import 'package:http/http.dart' as http;
import 'sign_in.dart';
import 'package:email_validator/email_validator.dart';

class SignUp extends StatefulWidget {
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

  List<String> _clubs = [
    'Wink',
    'D-Alpha', 
    'KoBot', 
    'Poska',
    ];
  List<String> _faculties = [
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
      title: Padding(
        padding: EdgeInsets.only(right: 70.0, top:20.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '회원가입',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(30.0), 
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Divider(
            color: Color(0xFFDFDFDF),
            thickness: 1.0,
          ),
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
              SizedBox(height: 20),
               Padding(
                padding: const EdgeInsets.only(right: 220),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('이름을 입력하세요', controller: nameController),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 220),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('학번을 입력하세요', controller: studentIdController),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 195),
                child: const Text(
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
              SizedBox(height: 10),
              buildDropdownField('단과대학', _faculties, _selectedFaculty),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 220),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('학과를 입력하세요', controller: departmentController),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 180),
                child: const Text(
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
              SizedBox(height: 10),
              buildDropdownField('소속 동아리', _clubs, _selectedClub),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 170),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('example@kookmin.ac.kr', controller: emailController),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 195),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('비밀번호를 입력하세요',
                  isPassword: true, controller: passwordController),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 175),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('비밀번호를 입력하세요',
                  isPassword: true, controller: confirmPasswordController),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 180),
                child: const Text(
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
              SizedBox(height: 10),
              buildInputField('휴대폰 번호를 입력하세요', controller: phoneController),
              const SizedBox(height: 10),
              
              Padding(
              padding: EdgeInsets.only(left: 35.0), // Row 위쪽에 10 픽셀의 여백 추가
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
              style: TextStyle(color: Color(0xFF7A7A7A)),
      ),
    ],
  ),
),
              Container(
                  width: double.infinity,
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
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
                    backgroundColor: const Color(0xFF3694A8),
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
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                    },
                    child: const Text("로그인",
                        style: TextStyle(color: Color(0xFF141D5B))),
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
        color: Color(0x4FECECEC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: TextField(
      obscureText: isPassword,
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF9C9C9C)),
        ),
        border: InputBorder.none,
        filled: true,
        fillColor: Color.fromARGB(255, 246, 246, 246),
      ),
      ),
    );
  }

Widget buildDropdownField(String labelText, List<String> items, String? value) {
  return Container(
    width: 265.75,
    height: 28.97,
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle: TextStyle(
          color: Color(0xFF9C9C9C),
          fontSize: 13,
          ),
        filled: true,
        fillColor: Color.fromARGB(255, 246, 246, 246),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
          borderSide: BorderSide(color: Colors.transparent),
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
            style: TextStyle(fontSize: 12),),
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
    const url = 'http://localhost:3000/auth/signup';
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
          MaterialPageRoute(builder: (context) => SignupSuccess()),
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

import 'package:flutter/material.dart';
import 'package:frontend/loading.dart';
import 'package:frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_up.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

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
    if (isLoading) {
      return const LoadingScreen();
    } else {
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
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.only(right: 220),
                  child: Text(
                    '아이디',
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
                Container(
                  child: buildInputField(
                    '아이디를 입력하세요',
                    controller: emailController,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(right: 220),
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
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0), // 원하는 좌측 padding 값 설정
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: const Color(0xFF004F9E),
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
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await loginUser(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004F9E),
                    minimumSize: const Size(265.75, 39.46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  child: Text(
                    isLoading ? '로딩 중...' : '로그인',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 265.75,
                  height: 39.46,
                  child: SignInButton(
                    Buttons.google,
                    text: "      Google로 로그인",
                    onPressed: () async {
                      try {
                        UserCredential userCredential =
                            await signInWithGoogle(context);
                        if (userCredential.user != null) {
                          String uid = userCredential.user!.uid;
                          await saveTokenToSharedPreferences(isChecked, uid);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = 'Google 로그인 실패: $e';
                        });
                      }
                    },
                  ),
                ),
                const Divider(
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
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUp()),
                        );
                      },
                      child: const Text("회원가입",
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
  }

  Future<void> saveTokenToSharedPreferences(bool isChecked, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (isChecked == true) {
      prefs.setString('token', 'true');
      prefs.setString('uid', uid);
    } else if (isChecked == false) {
      prefs.setString('token', 'false');
      prefs.setString('uid', uid);
    }
    // 자동로그인 체크되어있으면 토큰 발급
  }

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw Exception("Google sign-in was cancelled");
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Google sign-in failed: $e");
      rethrow; // Rethrow the exception to be handled in the caller
    }
  }

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true; // 요청 시작 시 로딩 시작
    });

    const url = 'http://3.35.96.145:3000/auth/signin';
    final Map<String, String> data = {
      'email': emailController.text,
      'password': passwordController.text,
      'fcmToken': 'fcmToken',
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      isLoading = false; // 요청 완료 시 로딩 숨김
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Signin successful') {
        saveTokenToSharedPreferences(isChecked, responseData['uid']);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
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
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
          filled: true,
          fillColor: const Color(0xFFEDEDED),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9C9C9C)),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEDEDED)),
          ),
        ),
      ),
    );
  }
}

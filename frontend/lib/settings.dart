import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();
  TextEditingController facultyController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController clubController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원정보 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputField('이름', controller: nameController),
            buildInputField('이메일', controller: emailController),
            buildInputField('학번', controller: studentIdController),
            buildInputField('소속 단과대학', controller: facultyController),
            buildInputField('학부', controller: departmentController),
            buildInputField('소속 동아리', controller: clubController),
            buildInputField('휴대폰 번호', controller: phoneController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle update profile action
              },
              child: const Text('회원정보 수정'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(String labelText, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
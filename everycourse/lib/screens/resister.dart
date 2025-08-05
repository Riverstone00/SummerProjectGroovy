import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: RegistrationPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontSize: 20,
            color: Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            _buildTextField(label: '이름'),
            const SizedBox(height: 16),
            _buildTextField(label: '이메일'),
            const SizedBox(height: 16),
            _buildTextField(label: '비밀번호', obscureText: true),
            const SizedBox(height: 16),
            _buildTextField(label: '비밀번호 확인', obscureText: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // 회원가입 처리 로직
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // 로그인 페이지로 이동
              },
              child: const Text(
                '이미 계정이 있으신가요? 로그인',
                style: TextStyle(color: Colors.pink),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: '$label 입력',
          ),
        ),
      ],
    );
  }
}

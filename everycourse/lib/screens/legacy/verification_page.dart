import 'package:flutter/material.dart';

class VerificationPage extends StatelessWidget {
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인증코드 입력'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Text(
          '$email 주소로 인증코드가 전송되었습니다.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

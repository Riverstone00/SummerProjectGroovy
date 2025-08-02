import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: VerificationPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _codeSent = false;

  void _sendCode() {
    setState(() {
      _codeSent = true;
    });
    // 실제 발송 로직: API 호출 또는 Firebase Auth SMS/email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증코드가 발송되었습니다.')),
    );
  }

  void _verifyCode() {
    final enteredCode = _codeController.text;
    if (enteredCode == '123456') {
      // 테스트용 성공 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증에 성공했습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증코드가 올바르지 않습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '인증 코드 확인',
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이메일 또는 휴대폰으로 전송된 인증코드를 입력하세요.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            if (!_codeSent)
              ElevatedButton(
                onPressed: _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('인증코드 발송', style: TextStyle(color: Colors.white)),
              ),

            if (_codeSent) ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '인증코드 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('인증하기', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


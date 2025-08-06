import 'package:flutter/material.dart';
import '../services/student_verification_service.dart';

class StudentVerificationScreen extends StatefulWidget {
  const StudentVerificationScreen({super.key});

  @override
  State<StudentVerificationScreen> createState() =>
      _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final StudentVerificationService _verificationService =
      StudentVerificationService();
  bool _isLoading = false;
  bool _emailSent = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _requestVerification() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage('학교 이메일을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await _verificationService.requestStudentVerification(
        _emailController.text.trim(),
      );

      if (result['success'] == true) {
        setState(() {
          _emailSent = true;
          _message = result['message'] ?? '인증 이메일을 발송했습니다.';
        });

        // 실제 배포용: 사용자가 이메일에서 받은 코드를 직접 입력하도록 함
      } else {
        _showMessage(result['message'] ?? '인증 요청에 실패했습니다.');
      }
    } catch (e) {
      print('Error requesting verification: $e');
      _showMessage('인증 요청 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyToken() async {
    if (_tokenController.text.trim().isEmpty) {
      _showMessage('인증 코드를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await _verificationService.verifyEmail(
        _tokenController.text.trim(),
      );

      if (result['success'] == true) {
        _showMessage(result['message'] ?? '학생 인증이 완료되었습니다!');
        // 잠시 후 이전 화면으로 돌아가기
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true); // 인증 완료 상태로 돌아가기
          }
        });
      } else {
        _showMessage(result['message'] ?? '인증에 실패했습니다.');
      }
    } catch (e) {
      print('Error verifying token: $e');
      _showMessage('인증 확인 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    super.dispose();
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
          '학생 인증',
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 아이콘과 제목
            Center(
              child: Column(
                children: [
                  Icon(Icons.school, size: 80, color: Colors.pink.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    '학생 인증',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '학교 이메일로 학생 인증을 받으세요',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            if (!_emailSent) ...[
              // 이메일 입력 단계
              const Text(
                '학교 이메일을 입력하시오:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '.ac.kr 또는 .edu.kr로 끝나는 학교 이메일만 인증 가능합니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '학교 이메일',
                  hintText: 'example@university.ac.kr',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.pink),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '인증 이메일 발송',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ] else ...[
              // 토큰 입력 단계
              const Text(
                '인증 이메일을 확인하세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_emailController.text}로 인증 링크를 발송했습니다.\n이메일을 확인하고 링크를 클릭하세요.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: '인증 코드 (선택사항)',
                  hintText: '이메일의 코드를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.verified, color: Colors.pink),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '인증 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // 다시 발송 버튼
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                      _tokenController.clear();
                    });
                  },
                  child: const Text(
                    '다시 발송',
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 메시지 표시
            if (_message.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.contains('완료') || _message.contains('발송')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message.contains('완료') || _message.contains('발송')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('완료') || _message.contains('발송')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

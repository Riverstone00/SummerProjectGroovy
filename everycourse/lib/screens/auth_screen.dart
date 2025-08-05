import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService(); // UserService 인스턴스 추가
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고/제목
              Icon(
                Icons.school,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'EveryCourse',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                '캠퍼스 중심 데이트 코스를 추천해드려요',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // 이메일 입력
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              
              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              
              // 로그인/회원가입 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isSignUp ? '회원가입' : '로그인'),
                ),
              ),
              const SizedBox(height: 10),
              
              // 전환 버튼
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(_isSignUp 
                    ? '이미 계정이 있나요? 로그인하기' 
                    : '계정이 없나요? 회원가입하기'),
              ),
              const SizedBox(height: 20),
              
              // 익명 로그인
              TextButton(
                onPressed: () => _signInAnonymously(),
                child: const Text('익명으로 계속하기'),
              ),
              
              const SizedBox(height: 20),
              
              // 구분선
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('또는', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Google 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Image.network(
                    'https://developers.google.com/identity/images/g-logo.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text('Google로 로그인'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      if (_isSignUp) {
        // UserService를 통한 회원가입 (Firestore 프로필 생성 포함)
        await _userService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 완료되었습니다! 🎉')),
          );
        }
      } else {
        // UserService를 통한 로그인 (Firestore 프로필 동기화 포함)
        await _userService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_isSignUp ? '회원가입' : '로그인'} 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      // UserService를 통한 익명 로그인 (Firestore 프로필 생성 포함)
      await _userService.signInAnonymously();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('익명으로 로그인되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('익명 로그인 실패: $e')),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('🔄 Starting Google Sign-In process...');
      
      // Google Sign-In 설정 (웹 클라이언트 ID 명시)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Firebase 콘솔에서 가져온 웹 클라이언트 ID
        clientId: '1058242387574-d5nsfus1gt0hh09i13mqnqc48ggn37nc.apps.googleusercontent.com',
      );
      
      // Google Sign-In 트리거
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // 사용자가 로그인을 취소한 경우
      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      print('✅ Google Sign-In successful for: ${googleUser.email}');

      // 인증 정보 얻기
      print('🔄 Getting Google authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      print('✅ Got Google auth tokens');

      // Firebase 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔄 Signing in to Firebase with Google credentials...');

      // UserService를 통한 구글 로그인 (Firestore 프로필 생성 포함)
      await _userService.signInWithGoogle(credential);
      
      print('✅ Firebase Google Sign-In successful!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 로그인 성공! 🎉')),
        );
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      if (e.toString().contains('ApiException: 10')) {
        print('🚨 Google Sign-In 설정 오류! Firebase 콘솔에서 SHA-1 지문을 확인해주세요.');
        print('🔧 필요한 SHA-1: 7D:B3:88:ED:44:26:C5:22:CD:69:52:F8:FF:DE:98:68:D4:3E:D8:BB');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

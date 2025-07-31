import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
              
              const SizedBox(height: 10),
              
              // 카카오 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithKakao,
                  icon: const Icon(Icons.chat_bubble, color: Colors.brown),
                  label: const Text('카카오로 로그인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // 네이버 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithNaver,
                  icon: const Text('N', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  label: const Text('네이버로 로그인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03C75A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
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

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('익명 로그인 실패: $e')),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Google Sign-In 트리거
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      // 사용자가 로그인을 취소한 경우
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 인증 정보 얻기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithKakao() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 카카오톡 앱이 설치되어 있는지 확인
      if (await kakao.isKakaoTalkInstalled()) {
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 가져오기
      final kakao.User kakaoUser = await kakao.UserApi.instance.me();
      
      // Firebase Custom Token 생성 (서버에서 처리해야 함)
      // 현재는 익명 로그인으로 대체
      await FirebaseAuth.instance.signInAnonymously();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 성공: ${kakaoUser.kakaoAccount?.profile?.nickname ?? "사용자"}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithNaver() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      
      if (result.status == NaverLoginStatus.loggedIn) {
        // Firebase Custom Token 생성 (서버에서 처리해야 함)
        // 현재는 익명 로그인으로 대체
        await FirebaseAuth.instance.signInAnonymously();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('네이버 로그인 성공: ${result.account.nickname}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('네이버 로그인이 취소되었습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네이버 로그인 실패: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

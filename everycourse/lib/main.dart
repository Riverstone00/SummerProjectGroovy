import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' hide User;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  // 카카오 SDK 초기화 (실제 네이티브 앱 키로 교체 필요)
  KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY');
  
  // 네이버 로그인 초기화 (실제 클라이언트 ID/Secret으로 교체 필요)
  await FlutterNaverLogin.initSdk(
    clientId: "YOUR_NAVER_CLIENT_ID",
    clientSecret: "YOUR_NAVER_CLIENT_SECRET",
    clientName: "EveryCourse",
  );
  
  // Debug 모드에서도 Analytics 활성화
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  runApp(const EveryCourseApp());
}

class EveryCourseApp extends StatelessWidget {
  const EveryCourseApp({super.key});

  // Firebase Analytics 인스턴스
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = 
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EveryCourse',
      theme: ThemeData(
        // EveryCourse 앱의 테마 설정
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorObservers: [observer],
      // 인증 상태에 따른 화면 라우팅
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 연결 상태 확인 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // 로그인 상태에 따른 화면 분기
          if (snapshot.hasData) {
            // 사용자가 로그인되어 있음 → 홈 화면
            return const HomeScreen();
          } else {
            // 사용자가 로그인되어 있지 않음 → 인증 화면
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

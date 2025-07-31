import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _sendAppStartEvent();
    _loadCounterFromFirestore();
  }

  // Firestore에서 카운터 값 불러오기
  void _loadCounterFromFirestore() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('countings').doc('main_counter').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _counter = data['value'] ?? 0;
        });
        print('Firestore에서 카운터 값 로드: $_counter');
      }
    } catch (e) {
      print('Firestore 읽기 오류: $e');
    }
  }

  // Firestore에 카운터 값 저장하기
  void _saveCounterToFirestore() async {
    try {
      await _firestore.collection('countings').doc('main_counter').set({
        'value': _counter,
        'lastUpdated': FieldValue.serverTimestamp(),
        'device': 'flutter_app',
      });
      print('Firestore에 카운터 값 저장: $_counter');
    } catch (e) {
      print('Firestore 저장 오류: $e');
    }
  }

  void _sendAppStartEvent() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'app_open',
      parameters: {
        'screen_name': 'home_page',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    print('Firebase Analytics 앱 시작 이벤트 전송');
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    
    // Firestore에 카운터 값 저장
    _saveCounterToFirestore();
    
    // Firebase Analytics 이벤트 전송
    await FirebaseAnalytics.instance.logEvent(
      name: 'button_pressed',
      parameters: {
        'counter_value': _counter,
        'screen_name': 'home_page',
      },
    );
    
    print('Firebase Analytics 이벤트 전송: button_pressed, counter: $_counter');
  }

  // 로그아웃 함수
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('사용자 로그아웃 완료');
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EveryCourse'),
        actions: [
          // 사용자 정보 표시
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                user?.displayName ?? user?.email ?? 'Anonymous',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          // 로그아웃 버튼
          IconButton(
            onPressed: () => _signOut(),
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              '🔥 Firebase Firestore 연동됨',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '카운터 값이 실시간으로 저장됩니다',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              const Divider(),
              const Text('로그인된 사용자 정보:'),
              Text('UID: ${user.uid}'),
              Text('이메일: ${user.email ?? 'N/A'}'),
              Text('익명: ${user.isAnonymous ? 'Yes' : 'No'}'),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

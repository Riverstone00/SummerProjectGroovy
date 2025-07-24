import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Debug 모드에서도 Analytics 활성화
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Firebase Analytics 인스턴스
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = 
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
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
      home: const MyHomePage(title: 'EveryCourse'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      DocumentSnapshot doc = await _firestore.collection('counters').doc('main_counter').get();
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
      await _firestore.collection('counters').doc('main_counter').set({
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
    await MyApp.analytics.logEvent(
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
    await MyApp.analytics.logEvent(
      name: 'button_pressed',
      parameters: {
        'counter_value': _counter,
        'screen_name': 'home_page',
      },
    );
    
    print('Firebase Analytics 이벤트 전송: button_pressed, counter: $_counter');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

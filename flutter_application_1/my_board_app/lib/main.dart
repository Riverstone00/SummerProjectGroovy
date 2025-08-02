// lib/main.dart
import 'package:flutter/material.dart';
import 'models/post.dart';
import 'screens/home_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/write_screen.dart';

void main() {
  runApp(const MyBoardApp());
}

class MyBoardApp extends StatelessWidget {
  const MyBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '게시판 앱',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
            .copyWith(secondary: Colors.pinkAccent),
      ),
      home: const MainScreen(), // 별도 위젯으로 분리
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Post> _posts = [];

  void _addNewPost(Post post) {
    setState(() {
      _posts.insert(0, post);
      _currentIndex = 1; // 게시글 추가 후 게시 탭으로 이동
    });
  }

  void _navigateToWriteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteScreen(onAdd: _addNewPost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      FeedScreen(posts: _posts, onWritePressed: _navigateToWriteScreen),
      const MyPageScreen(), // 마이페이지 화면 추가
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 등록한 코스 보기'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed, // 3개 탭을 위해 추가
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: '탐색'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: '게시'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}

// 마이페이지 화면 추가
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '마이페이지',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

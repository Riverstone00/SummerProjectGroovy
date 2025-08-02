import 'package:flutter/material.dart';

class FullCoursePage extends StatelessWidget {
  const FullCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테마별 코스 전체 보기'),
      ),
      body: const Center(
        child: Text('여기에 테마별 코스 리스트를 추가할 예정입니다.'),
      ),
    );
  }
}

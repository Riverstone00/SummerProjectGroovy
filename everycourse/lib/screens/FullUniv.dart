import 'package:flutter/material.dart';

class FullUnivPage extends StatelessWidget {
  const FullUnivPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대학생의 숨은 데이트 코스 전체 보기'),
      ),
      body: const Center(
        child: Text('여기에 대학별 데이트 코스 리스트를 추가할 예정입니다.'),
      ),
    );
  }
}

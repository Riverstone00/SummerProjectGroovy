import 'package:everycourse/utils/dummy_data_manager.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  final DummyDataManager _dummyDataManager = DummyDataManager();

  AdminPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 패널'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 로딩 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('더미 데이터를 추가하는 중...')),
                );
                
                // 더미 데이터 추가
                await _dummyDataManager.addAllDummyData();
                
                // 완료 메시지
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('더미 데이터 추가가 완료되었습니다.')),
                );
              },
              child: const Text('더미 데이터 추가'),
            ),
          ],
        ),
      ),
    );
  }
}

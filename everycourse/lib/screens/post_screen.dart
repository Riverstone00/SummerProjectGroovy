import 'package:flutter/material.dart';
import '../services/course_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final CourseService _courseService = CourseService();
  bool _isUploading = false;
  String _resultMessage = '';
  
  // 더미 코스 데이터 정의
  final List<Map<String, dynamic>> dummyCourses = [
    {
      "title": "날씨 좋은 봄, 동대냥이와 함께",
      "location": "동국대학교",
      "price": "5만원 이하",
      "time": "3.5시간",
      "priceAmount": 50000,
      "timeMinutes": 210,
      "description": "동국대학교 캠퍼스에서 봄을 느끼며 산책하는 코스입니다. 학교 내 명소와 함께 귀여운 캠퍼스 고양이도 만날 수 있어요!",
      "image": "assets/images/test.jpg"
    },
    {
      "title": "동대 주변 힐링 카페 투어",
      "location": "동국대학교",
      "price": "10만원 이하",
      "time": "4시간",
      "priceAmount": 80000,
      "timeMinutes": 240,
      "description": "동국대학교 주변의 분위기 좋은 카페들을 탐방하는 코스입니다. 공부와 데이트 모두 가능한 카페들이 모여있어요.",
      "image": "assets/images/course2.png"
    },
    {
      "title": "동대-남산 힐링 산책로",
      "location": "동국대학교",
      "price": "3만원 이하",
      "time": "3.5시간",
      "priceAmount": 30000,
      "timeMinutes": 210,
      "description": "동국대학교에서 시작해 남산으로 이어지는 아름다운 산책로를 따라 걷는 코스입니다. 서울의 중심에서 자연을 느껴보세요.",
      "image": "assets/images/course3.png"
    },
    {
      "title": "동국대 맛집 데이트",
      "location": "동국대학교",
      "price": "5만원 이하",
      "time": "3시간",
      "priceAmount": 50000,
      "timeMinutes": 180,
      "description": "동국대학교 주변의 숨은 맛집들을 탐방하는 코스입니다. 분위기 좋은 식당들에서 다양한 음식을 즐겨보세요.",
      "image": "assets/images/course4.png"
    },
  ];

  // Firestore에 더미 데이터 업로드 함수
  Future<void> _uploadDummyCourses() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _resultMessage = '업로드 중...';
    });

    try {
      // 더미 데이터 추가 (지정된 사용자 ID 사용)
      final courseIds = await _courseService.addDummyCoursesToFirestore(
        dummyCourses, 
        "ZN10alAlbrfpGn8VqRoTgqVWzRD3"
      );
      
      setState(() {
        _resultMessage = '성공: ${dummyCourses.length}개의 더미 코스가 추가되었습니다.\n문서 ID: ${courseIds.join(", ")}';
      });
    } catch (e) {
      setState(() {
        _resultMessage = '오류: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('코스 데이터 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadDummyCourses,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(_isUploading ? '업로드 중...' : '더미 코스 데이터 추가'),
              ),
              const SizedBox(height: 24),
              if (_resultMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _resultMessage.startsWith('오류') ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _resultMessage,
                    style: TextStyle(
                      color: _resultMessage.startsWith('오류') ? Colors.red[900] : Colors.green[900],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

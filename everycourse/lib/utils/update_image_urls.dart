import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:everycourse/services/course_service.dart';

class UpdateCoursesImageUrls extends StatefulWidget {
  const UpdateCoursesImageUrls({super.key});

  @override
  State<UpdateCoursesImageUrls> createState() => _UpdateCoursesImageUrlsState();
}

class _UpdateCoursesImageUrlsState extends State<UpdateCoursesImageUrls> {
  final CourseService _courseService = CourseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _isLoading = false;
  String _statusMessage = '';
  int _updatedCount = 0;
  int _totalCount = 0;
  List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 URL 업데이트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '코스 문서에 이미지 URL 추가하기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('이 도구는 Firestore의 모든 코스 문서에 이미지 URL을 추가합니다.'),
            Text('Firebase Storage 경로: gs://everycourse-911af.firebasestorage.app/images'),
            const SizedBox(height: 20),
            if (_isLoading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _totalCount > 0 ? _updatedCount / _totalCount : null,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF49CA2)),
                  ),
                  const SizedBox(height: 10),
                  Text('처리 중... ($_updatedCount / $_totalCount)'),
                ],
              )
            else
              ElevatedButton(
                onPressed: _updateImageUrls,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF49CA2),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text('이미지 URL 업데이트 시작'),
              ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: _statusMessage.contains('오류') ? Colors.red : Colors.black,
              ),
            ),
            if (_logs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('로그:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _logs[_logs.length - 1 - index],
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: _logs[_logs.length - 1 - index].contains('오류') 
                                ? Colors.red 
                                : Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('[${DateTime.now().toString().split('.').first}] $log');
    });
  }

  Future<void> _updateImageUrls() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '데이터 로드 중...';
      _updatedCount = 0;
      _logs = [];
    });

    try {
      // Firebase Storage에서 이미지 URL 가져오기
      _addLog('Firebase Storage에서 이미지 목록 가져오는 중...');
      
      Map<String, String> imageUrlMap = {};
      try {
        final ListResult result = await _storage.ref('images').listAll();
        
        for (var item in result.items) {
          final String fileName = item.name;
          final String downloadUrl = await item.getDownloadURL();
          imageUrlMap[fileName] = downloadUrl;
        }
        
        _addLog('Firebase Storage에서 ${imageUrlMap.length}개의 이미지를 찾았습니다.');
      } catch (e) {
        _addLog('이미지 목록 가져오기 실패: $e');
        
        // 오류 발생 시 기본 이미지 URL 사용
        _addLog('기본 이미지 URL을 사용합니다.');
        imageUrlMap = {
          'course1.png': 'https://firebasestorage.googleapis.com/v0/b/everycourse-911af/o/images%2Fcourse1.png?alt=media',
          'course2.png': 'https://firebasestorage.googleapis.com/v0/b/everycourse-911af/o/images%2Fcourse2.png?alt=media',
          'course3.png': 'https://firebasestorage.googleapis.com/v0/b/everycourse-911af/o/images%2Fcourse3.png?alt=media',
          'course4.png': 'https://firebasestorage.googleapis.com/v0/b/everycourse-911af/o/images%2Fcourse4.png?alt=media',
        };
      }
      
      if (imageUrlMap.isEmpty) {
        throw Exception('사용 가능한 이미지가 없습니다.');
      }

      // 모든 코스 가져오기
      _addLog('Firestore에서 코스 문서 가져오는 중...');
      final snapshot = await _firestore.collection('courses').get();
      final courses = snapshot.docs;
      
      setState(() {
        _totalCount = courses.length;
        _statusMessage = '$_totalCount개의 코스를 찾았습니다. URL 업데이트 중...';
      });

      _addLog('$_totalCount개의 코스 문서를 찾았습니다.');

      // 각 코스 문서에 이미지 URL 추가 (배치 처리)
      final List<String> imageKeys = imageUrlMap.keys.toList();
      final batch = _firestore.batch();
      int batchCount = 0;
      
      for (int i = 0; i < courses.length; i++) {
        final doc = courses[i];
        final data = doc.data();
        
        // 이미 이미지 URL이 있는 경우 건너뛰기
        if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
          _addLog('코스 "${data['title'] ?? '제목 없음'}"(${doc.id}) - 이미 이미지 URL이 있습니다.');
          continue;
        }
        
        // 순환하면서 이미지 할당
        final imageKey = imageKeys[i % imageKeys.length];
        final imageUrl = imageUrlMap[imageKey]!;
        
        batch.update(doc.reference, {'imageUrl': imageUrl});
        batchCount++;
        
        _addLog('코스 "${data['title'] ?? '제목 없음'}"(${doc.id}) - ${imageKey} 이미지 할당');
        
        // 100개 단위로 커밋
        if (batchCount >= 100) {
          await batch.commit();
          setState(() {
            _updatedCount += batchCount;
            _statusMessage = '$_updatedCount / $_totalCount 완료';
          });
          batchCount = 0;
        }
      }
      
      // 남은 배치 커밋
      if (batchCount > 0) {
        await batch.commit();
        setState(() {
          _updatedCount += batchCount;
        });
      }

      setState(() {
        _isLoading = false;
        _statusMessage = '완료! $_updatedCount개 코스에 이미지 URL이 추가되었습니다.';
        _addLog('작업 완료: $_updatedCount개 코스 업데이트됨');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '오류 발생: $e';
        _addLog('오류 발생: $e');
      });
    }
  }
}

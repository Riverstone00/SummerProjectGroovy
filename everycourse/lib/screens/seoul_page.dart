import 'package:flutter/material.dart';
import 'course_list.dart'; // 코스 리스트 페이지 import
import 'package:everycourse/services/course_service.dart';

class SeoulPage extends StatefulWidget {
  const SeoulPage({super.key});

  @override
  State<SeoulPage> createState() => _SeoulPageState();
}

class _SeoulPageState extends State<SeoulPage> {
  final CourseService _courseService = CourseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> universities = [];

  @override
  void initState() {
    super.initState();
    _loadUniversitiesData();
  }

  Future<void> _loadUniversitiesData() async {
    try {
      // 각 대학별 데이터를 가져오기
      final List<Map<String, dynamic>> seoulUniversities = [
        {"name": "동국대학교", "image": "assets/images/dongguk2.jpg", "desc": "남산 자락에 위치한 전통과 현대가 어우러진 캠퍼스. 도심 속에서도 조용하고 여유로운 분위기를 느낄 수 있어요."},
        {"name": "연세대학교", "image": "assets/images/yonsei.jpg", "desc": "신촌의 위치로 복잡하지만 분위기 좋고 산책도 가능."},
        {"name": "홍익대학교", "image": "assets/images/honggik.jpg", "desc": "예술적인 감성이 가득한 캠퍼스. 개성있는 데이트 코스로 추천."},
        {"name": "성균관대학교", "image": "assets/images/sung.jpg", "desc": "조용하고 전통이 있는 분위기. 조경이 잘 되어 있어 여유롭게 걷기 좋아요."},
        {"name": "건국대학교", "image": "assets/images/konkuk.jpg", "desc": "호수와 캠퍼스가 어우러져 분위기 최고! 넓고 쾌적한 캠퍼스로 산책 코스로 추천."},
      ];

      // 각 대학에 대해 실시간 데이터 추가
      List<Map<String, dynamic>> updatedUniversities = [];
      
      for (var uni in seoulUniversities) {
        // 대학 이름으로 관련 코스 검색
        final courses = await _courseService.getCoursesByHashtag(uni["name"]);
        
        // 평균 평점 계산
        double avgRating = 0;
        int reviewCount = 0;
        int totalViews = 0;
        int courseCount = courses.length; // 코스 개수 추가
        
        if (courses.isNotEmpty) {
          double sumRating = 0;
          for (var course in courses) {
            if (course['rating'] != null) {
              sumRating += (course['rating'] as num).toDouble();
            }
            if (course['reviewCount'] != null) {
              reviewCount += (course['reviewCount'] as num).toInt();
            }
            if (course['viewcount'] != null) {
              totalViews += (course['viewcount'] as num).toInt();
            }
          }
          
          // 평균 계산 (코스가 있는 경우에만)
          if (courses.length > 0) {
            avgRating = sumRating / courses.length;
          }
        }
        
        // 실시간 데이터를 추가하여 새 대학 객체 생성
        final updatedUni = {
          ...uni,
          "rating": avgRating > 0 ? double.parse(avgRating.toStringAsFixed(1)) : 0.0,
          "review": reviewCount,
          "viewCount": totalViews,
          "courseCount": courseCount, // 코스 개수 추가
        };
        
        updatedUniversities.add(updatedUni);
      }
      
      setState(() {
        universities = updatedUniversities;
        _isLoading = false;
      });
    } catch (e) {
      print('대학 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서울'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: universities.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final u = universities[index];
                return GestureDetector(
                  onTap: () {
                    // 각 대학교 클릭 시 해당 이름을 CourseList로 넘김
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseList(universityName: u["name"] as String),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            u['image'],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    u['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  Text('${u["rating"]}'),
                                  const Spacer(),
                                  Text(
                                    '(${u["courseCount"]})',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                u['desc'],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.remove_red_eye, 
                                      color: Colors.grey, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${u["viewCount"] ?? 0}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.menu_book_outlined, 
                                      color: Colors.grey, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '코스 ${u["courseCount"] ?? 0}개',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

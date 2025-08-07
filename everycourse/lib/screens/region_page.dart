import 'package:flutter/material.dart';
import 'course_list.dart';
import 'package:everycourse/services/course_service.dart';
import 'package:everycourse/services/region_service.dart';

class RegionPage extends StatefulWidget {
  final String regionId;
  final String regionName;
  
  const RegionPage({
    super.key, 
    required this.regionId,
    required this.regionName,
  });

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  final CourseService _courseService = CourseService();
  final RegionService _regionService = RegionService();
  bool _isLoading = true;
  List<Map<String, dynamic>> universities = [];

  @override
  void initState() {
    super.initState();
    _loadUniversitiesData();
  }

  Future<void> _loadUniversitiesData() async {
    try {
      // RegionService에서 동적 이미지가 적용된 학교 목록 가져오기
      final schools = await _regionService.getSchoolsWithDynamicImages(widget.regionId);
      
      // 각 학교에 대해 실시간 코스 데이터 추가
      List<Map<String, dynamic>> updatedUniversities = [];
      
      for (var school in schools) {
        // 학교 이름으로 관련 코스 검색 (해시태그 또는 location으로)
        final courses = await _courseService.getCoursesByHashtagOrLocation(school["name"]);
        
        // 평균 평점 계산
        double avgRating = 0;
        int reviewCount = 0;
        int totalViews = 0;
        int courseCount = courses.length;
        
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
          
          if (courses.length > 0) {
            avgRating = sumRating / courses.length;
          }
        }
        
        // 실시간 데이터를 추가하여 새 대학 객체 생성
        final updatedUni = {
          ...school,
          "rating": avgRating > 0 ? double.parse(avgRating.toStringAsFixed(1)) : 0.0,
          "review": reviewCount,
          "viewCount": totalViews,
          "courseCount": courseCount,
        };
        
        updatedUniversities.add(updatedUni);
      }
      
      setState(() {
        universities = updatedUniversities;
        _isLoading = false;
      });
      
    } catch (e) {
      print('RegionPage: 지역 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.regionName),
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
                          child: _buildUniversityImage(u),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 설명 부분 제거 - 빈 공간으로 유지
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${u["rating"]}'),
                                  const SizedBox(width: 16),
                                  Icon(Icons.visibility, color: Colors.grey, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${u["viewCount"]}'),
                                  const SizedBox(width: 16),
                                  Icon(Icons.book, color: Colors.grey, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${u["courseCount"]}개 코스'),
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

  Widget _buildUniversityImage(Map<String, dynamic> university) {
    final imagePath = university['image'] as String?;
    
    if (imagePath == null || imagePath.isEmpty) {
      // 이미지가 없는 경우 기본 이미지 표시
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Icon(Icons.school, size: 40, color: Colors.grey),
      );
    }
    
    // assets 이미지인지 URL인지 확인
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 120,
          height: 120,
          color: Colors.grey[300],
          child: const Icon(Icons.school, size: 40, color: Colors.grey),
        ),
      );
    } else {
      // URL 이미지 (코스에서 가져온 이미지)
      return Image.network(
        imagePath,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 120,
          height: 120,
          color: Colors.grey[300],
          child: const Icon(Icons.school, size: 40, color: Colors.grey),
        ),
      );
    }
  }
}

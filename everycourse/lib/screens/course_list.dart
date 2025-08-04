import 'package:flutter/material.dart';
import 'course_detail.dart';
import 'package:everycourse/services/course_service.dart';

class CourseList extends StatefulWidget {
  final String universityName;
  const CourseList({super.key, required this.universityName});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  final CourseService _courseService = CourseService();
  String? selectedFilter;
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCoursesFromFirebase();
  }

  Future<void> _loadCoursesFromFirebase() async {
    try {
      // 대학 이름으로 코스 검색 (해시태그 기반)
      final courses = await _courseService.getCoursesByHashtag(widget.universityName);
      
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('코스 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 가격 필터링 함수
  bool _filterByPrice(Map<String, dynamic> course, String? filter) {
    if (filter == null) return true;
    
    final int price = course['priceAmount'] ?? 0;
    
    switch (filter) {
      case "3만원 이하":
        return price <= 30000;
      case "5만원 이하":
        return price <= 50000;
      case "10만원 이하":
        return price <= 100000;
      case "10만원 초과":
        return price > 100000;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = selectedFilter == null
        ? _courses
        : _courses.where((course) => _filterByPrice(course, selectedFilter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.universityName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double totalWidth = constraints.maxWidth;
                      final double spacing = 8;
                      final double buttonWidth = (totalWidth - spacing * 3) / 4;

                      final List<String> filters = [
                        "3만원 이하",
                        "5만원 이하",
                        "10만원 이하",
                        "10만원 초과"
                      ];

                      return Wrap(
                        spacing: spacing,
                        runSpacing: 8,
                        children: filters.map((label) {
                          final bool isSelected = selectedFilter == label;
                          return SizedBox(
                            width: buttonWidth,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = isSelected ? null : label;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? Colors.black54 : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF757575),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      itemCount: filteredCourses.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        
                        // 가격과 시간 포맷
                        final formatInfo = _courseService.formatPriceAndTime(course);
                        final formattedPrice = formatInfo['formattedPrice'] ?? '가격 정보 없음';
                        final formattedTime = formatInfo['formattedTime'] ?? '시간 정보 없음';
                        
                        return GestureDetector(
                          onTap: () {
                            // 조회수 증가 후 상세 페이지로 이동
                            _courseService.incrementCourseViewCount(course['courseId']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetail(course: course),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Builder(
                                  builder: (context) {
                                    // Firebase Storage에서 이미지 로드
                                    String? imageUrl = course['imageUrl'];
                                    if (imageUrl != null && imageUrl.isNotEmpty) {
                                      return Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 135,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('이미지 로드 오류($imageUrl): $error');
                                          // 오류 시 fallback으로 로컬 이미지 사용
                                          // courseId 기반으로 일관된 이미지 선택
                                          String courseId = course['courseId'] ?? course['id'] ?? '';
                                          int imageIndex = courseId.isEmpty 
                                              ? (index % 4) + 1 // 이전 로직 유지 (인덱스 기반)
                                              : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                                          return Image.asset(
                                            'assets/images/course$imageIndex.png',
                                            width: double.infinity,
                                            height: 135,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      );
                                    } else {
                                      // imageUrl이 없는 경우 로컬 이미지 사용
                                      // courseId 기반으로 일관된 이미지 선택
                                      String courseId = course['courseId'] ?? course['id'] ?? '';
                                      int imageIndex = courseId.isEmpty 
                                          ? (index % 4) + 1 // 이전 로직 유지 (인덱스 기반)
                                          : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                                      return Image.asset(
                                        'assets/images/course$imageIndex.png',
                                        width: double.infinity,
                                        height: 135,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                course['location'] ?? '위치 정보 없음',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                course['title'] ?? '제목 없음',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "💰 $formattedPrice  ⏱️ $formattedTime",
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ),
                                  if (course['rating'] != null)
                                    Text(
                                      "⭐ ${(course['rating'] as num).toStringAsFixed(1)}/10",
                                      style: const TextStyle(fontSize: 11, color: Colors.amber),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

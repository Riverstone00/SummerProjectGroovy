import 'package:flutter/material.dart';
import 'package:everycourse/services/course_service.dart';
import 'course_detail.dart';
import 'seoul_page.dart';
import 'full_univ.dart';
import 'full_course.dart';
import 'course_list.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CourseService _courseService = CourseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _popularCourses = [];
  List<Map<String, dynamic>> _universityRelatedCourses = [];
  List<Map<String, dynamic>> _themeCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCoursesFromFirebase();
  }

  Future<void> _loadCoursesFromFirebase() async {
    try {
      // Firestore에서 모든 코스 가져오기
      final allCourses = await _courseService.getAllCourses();
      
      // 코스가 비어있으면 로딩 상태 업데이트 후 종료
      if (allCourses.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // 조회수 기준으로 정렬하여 인기 코스 추출
      final sortedByViews = List<Map<String, dynamic>>.from(allCourses)
        ..sort((a, b) => (b['viewcount'] ?? 0).compareTo(a['viewcount'] ?? 0));
      
      // 해시태그로 대학 관련 코스 필터링
      final univCourses = allCourses.where((course) {
        final hashtags = course['hashtags'] as List<dynamic>?;
        return hashtags != null && 
               hashtags.any((tag) => tag.toString().contains('대학'));
      }).toList();
      
      // 기타 테마 코스 (인기 코스와 대학 코스를 제외한 나머지)
      final otherCourses = allCourses.where((course) {
        final hashtags = course['hashtags'] as List<dynamic>?;
        return hashtags != null && 
               !hashtags.any((tag) => tag.toString().contains('대학'));
      }).toList();
      
      setState(() {
        _popularCourses = sortedByViews.take(3).toList();
        _universityRelatedCourses = univCourses.take(5).toList();
        _themeCourses = otherCourses.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('코스 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildTopBanner(),
                  const SizedBox(height: 20),
                  _buildSectionWithMore(
                      context, "대학생의 숨은 데이트 코스", const FullUnivPage()),
                  const SizedBox(height: 20),
                  _buildHorizontalImageRow(
                      context, ['서울', '경기', '부산', '인천', '동국대학교', '홍익대학교', '연세대학교', '건국대학교'], isTheme: false),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.grey, thickness: 0.5),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionWithMore(context, "테마별 코스", const FullCoursePage()),
                  const SizedBox(height: 10),
                  _buildHorizontalImageRow(
                      context, ['감성 카페', '연인과 걷기 좋은 장소', '인생 포토존'], isTheme: true),
                  const SizedBox(height: 20),
                  _buildSectionTitle("인기 데이트 코스"),
                  _buildPopularCourse(),
                ],
              ),
      ),
    );
  }
  
  // 상단 배너
  Widget _buildTopBanner() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink.shade100, Colors.purple.shade100],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '캠퍼스 데이트 코스',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '대학생들이 추천하는\n캠퍼스 데이트 장소를 찾아보세요',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Image.asset(
              'assets/images/nothing.png',
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 제목 + 더보기
  Widget _buildSectionWithMore(
      BuildContext context, String title, Widget destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            },
            child: const Text(
              '더보기 >',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 가로 스크롤 이미지 목록
  Widget _buildHorizontalImageRow(
      BuildContext context, List<String> items, {required bool isTheme}) {
    return Container(
      height: isTheme ? 120 : 90,
      padding: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (!isTheme) {
                // 지역이나 대학교 이름을 클릭했을 때 CourseList로 이동
                if (items[index] == '서울') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SeoulPage()),
                  );
                } else {
                  // 다른 지역이나 대학교인 경우 CourseList로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseList(universityName: items[index]),
                    ),
                  );
                }
              }
            },
            child: Container(
              width: isTheme ? 180 : 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/images/nothing.png'),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  items[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 인기 데이트 코스
  Widget _buildPopularCourse() {
    // 인기 코스가 없으면 안내 메시지 표시
    if (_popularCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '인기 코스가 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (final course in _popularCourses)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  // 코스 상세 화면으로 이동 & 조회수 증가
                  _courseService.incrementCourseViewCount(course['courseId']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetail(course: course),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(10)),
                        child: course['imageUrl'] != null && course['imageUrl'].toString().isNotEmpty
                            ? Image.network(
                                course['imageUrl'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // courseId 기반으로 일관된 이미지 선택 (목록 화면과 동일한 방식)
                                  String courseId = course['courseId'] ?? course['id'] ?? '';
                                  int imageIndex = courseId.isEmpty 
                                      ? 1 
                                      : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                                  return Image.asset(
                                    'assets/images/course$imageIndex.png',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Builder(
                                builder: (context) {
                                  // imageUrl이 없는 경우도 courseId 기반으로 이미지 선택
                                  String courseId = course['courseId'] ?? course['id'] ?? '';
                                  int imageIndex = courseId.isEmpty 
                                      ? 1 
                                      : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                                  return Image.asset(
                                    'assets/images/course$imageIndex.png',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title'] ?? '제목 없음',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course['description'] ?? '이 코스는 대학생들에게 인기 있는 데이트 코스입니다.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.visibility, color: Colors.blue, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${course['viewcount'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (course['hashtags'] != null && (course['hashtags'] as List).isNotEmpty)
                                  ..._buildHashtags(course['hashtags']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 해시태그 위젯 생성
  List<Widget> _buildHashtags(List<dynamic> hashtags) {
    final result = <Widget>[];
    final maxTags = 2; // 최대 표시할 태그 수
    
    for (int i = 0; i < hashtags.length && i < maxTags; i++) {
      result.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '#${hashtags[i]}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ),
      );
    }
    
    return result;
  }
}

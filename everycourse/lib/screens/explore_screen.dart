import 'package:flutter/material.dart';
import 'package:everycourse/services/course_service.dart';
import 'package:everycourse/services/region_service.dart';
import 'course_detail.dart';
import 'region_page.dart';
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

  final RegionService _regionService = RegionService();
  final PageController _pageController = PageController();
  int _currentBannerPage = 0;

  bool _isLoading = true;
  List<Map<String, dynamic>> _popularCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCoursesFromFirebase();
  }

  // 지역의 실제 ID를 찾아 반환
  Future<String?> _getRegionId(String regionName) async {
    return await _regionService.findRegionByName(regionName);
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
                    context,
                    "대학생의 숨은 데이트 코스",
                    const FullUnivPage(),
                  ),
                  const SizedBox(height: 20),
                  _buildHorizontalImageRow(context, [
                    '서울',
                    '경기',
                    '부산',
                    '인천',
                  ], isTheme: false),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.grey, thickness: 0.5),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionWithMore(
                    context,
                    "테마별 코스",
                    const FullCoursePage(),
                  ),
                  const SizedBox(height: 10),
                  _buildHorizontalImageRow(context, [
                    '감성 카페',
                    '연인과 걷기 좋은 장소',
                    '인생 포토존',
                  ], isTheme: true),
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
    final bannerData = [
      {
        'image':
            'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fbanner.jpg?alt=media&token=15d71b97-8b0d-4a46-8e44-e01630552fce',
        'text': '핫플 데이트 코스\nTOP10',
        'textColor': Colors.black,
      },
      {
        'image':
            'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2FOrange%20Brown%20Cute%20Pet%20Shop%20Banner.png?alt=media&token=89cb994b-8af0-49d3-ac46-705d8d0a1188',
      },
      {
        'image':
            'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fbanner3.jpg?alt=media&token=0cf8c991-d867-4f56-953a-00f2e298dd3a',
      },
    ];

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: bannerData.length,
            onPageChanged: (index) {
              setState(() => _currentBannerPage = index);
            },
            itemBuilder: (context, index) {
              final banner = bannerData[index];
              return Stack(
                children: [
                  Image.network(
                    banner['image'] as String,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('이미지를 불러올 수 없습니다'));
                    },
                  ),
                  if (banner['text'] != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        banner['text'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: banner['textColor'] as Color? ?? Colors.white,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          //배너 넘기는 ... 설정
          Positioned(
            bottom: 7,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(bannerData.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentBannerPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 제목 + 더보기
  Widget _buildSectionWithMore(
    BuildContext context,
    String title,
    Widget destination,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                fontFamily: 'Cafe24Ssurround',
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
          fontFamily: 'Cafe24Ssurround',
        ),
      ),
    );
  }

  // 가로 스크롤 이미지 목록
  Widget _buildHorizontalImageRow(
    BuildContext context,
    List<String> items, {
    required bool isTheme,
  }) {
    final Map<String, String> imageUrls = {
      // 지역용
      '서울':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fseoul.jpg?alt=media&token=cece7482-0b0c-4527-a0f2-968bb4d587fb',
      '경기':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fgi.jpg?alt=media&token=a9f7b2c5-bddf-4fb1-a41f-56d5649453e1',
      '부산':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fbusan.jpg?alt=media&token=ce16af8f-2a5a-4926-a6d4-07b8a7c5caa8',
      '인천':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fincheon.jpg?alt=media&token=495ff287-b8c1-4424-9521-c28337de19f7',

      // 테마용
      '감성 카페':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fcaffee.jpg?alt=media&token=4050822b-c08c-4e11-81a3-06d649d8b47d',
      '연인과 걷기 좋은 장소':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fwalk.jpg?alt=media&token=d3dfd8d0-c965-416a-bf4e-2906e3f72ced',
      '인생 포토존':
          'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fphoto.jpg?alt=media&token=1a251ab0-93ba-455d-8b45-94ce677fa218',
    };

    return Container(
      height: isTheme ? 150 : 120, // 전체 높이는 사진+텍스트를 감쌈
      padding: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final imageUrl = imageUrls[item] ?? '';

          return GestureDetector(
            onTap: () {
              if (!isTheme) {
                // 모든 지역에 대해 통일된 처리
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder<String?>(
                      future: _getRegionId(item),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final regionId = snapshot.data;
                        if (regionId == null) {
                          return Scaffold(
                            body: Center(
                              child: Text('$item 지역 정보를 찾을 수 없습니다.'),
                            ),
                          );
                        }
                        
                        return RegionPage(
                          regionId: regionId, 
                          regionName: item
                        );
                      },
                    ),
                  ),
                );
              } else {
                // 테마별 클릭 시 해시태그로 필터링된 코스 목록으로 이동
                String hashtag;
                String title;
                
                switch (item) {
                  case '감성 카페':
                    hashtag = '카페';
                    title = '감성 카페 코스';
                    break;
                  case '연인과 걷기 좋은 장소':
                    hashtag = '산책';
                    title = '산책 코스';
                    break;
                  case '인생 포토존':
                    hashtag = '사진';
                    title = '포토존 코스';
                    break;
                  default:
                    return;
                }
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseList(
                      universityName: '', // 해시태그 검색이므로 빈 문자열
                      hashtag: hashtag,
                      title: title,
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: isTheme ? 180 : 90,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: isTheme ? 180 : 90,
                      height: isTheme ? 120 : 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: isTheme ? 180 : 90,
                          height: isTheme ? 120 : 90,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cafe24Ssurround',
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

   // 인기 데이트 코스
  Widget _buildPopularCourse() {
    if (_popularCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('인기 코스가 없습니다', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12), // ✅ 위쪽 간격
        SizedBox(
          height: 250, // 카드 전체 높이 지정
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _popularCourses.length,
            itemBuilder: (context, index) {
              final course = _popularCourses[index];
              return Container(
                width: 330,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child:
                              course['imageUrl'] != null &&
                                  course['imageUrl'].toString().isNotEmpty
                              ? Image.network(
                                  course['imageUrl'],
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    String courseId =
                                        course['courseId'] ??
                                        course['id'] ??
                                        '';
                                    int imageIndex = courseId.isEmpty
                                        ? 1
                                        : (courseId.hashCode % 4) + 1;
                                    return Image.asset(
                                      'assets/images/course$imageIndex.png',
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Builder(
                                  builder: (context) {
                                    String courseId =
                                        course['courseId'] ??
                                        course['id'] ??
                                        '';
                                    int imageIndex = courseId.isEmpty
                                        ? 1
                                        : (courseId.hashCode % 4) + 1;
                                    return Image.asset(
                                      'assets/images/course$imageIndex.png',
                                      height: 130,
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
                                  fontFamily: 'Cafe24Ssurround',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course['description'] ??
                                    '이 코스는 대학생들에게 인기 있는 데이트 코스입니다.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontFamily: 'Cafe24Ssurround',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${course['viewcount'] ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontFamily: 'Cafe24Ssurround',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (course['hashtags'] != null &&
                                      (course['hashtags'] as List).isNotEmpty)
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
              );
            },
          ),
        ),
      ],
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

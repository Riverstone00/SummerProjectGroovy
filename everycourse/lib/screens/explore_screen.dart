import 'package:flutter/material.dart';
import 'seoul_page.dart';
import 'full_univ.dart';
import 'full_course.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            _buildTopBanner(),
            const SizedBox(height: 20),
            _buildSectionWithMore(
                context, "대학생의 숨은 데이트 코스", const FullUnivPage()),
            const SizedBox(height: 20),
            _buildHorizontalImageRow(
                context, ['서울', '경기', '부산', '인천'], isTheme: false),
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
              if (!isTheme && items[index] == '서울') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SeoulPage()),
                );
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 1; i <= 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
                      child: Image.asset(
                        'assets/images/nothing.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '인기 데이트 코스 $i',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '이 코스는 대학생들에게 인기 있는 데이트 코스입니다.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.favorite, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '1.2k',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

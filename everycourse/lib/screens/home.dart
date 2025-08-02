import 'package:flutter/material.dart';
import 'SeoulPage.dart';
import 'FullUniv.dart';
import 'FullCourse.dart';

void main() {
  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '데이트 코스',
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '탐색'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '게시'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return SizedBox(
      height: 180,
      child: PageView(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/banner.jpg',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              const Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  '핫플 데이트 코스\nTOP10',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Image.asset(
                'assets/banner2.jpg',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              const Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  '대학생의 숨은 데이트 코스',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionWithMore(
      BuildContext context, String title, Widget targetPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalImageRow(BuildContext context, List<String> labels,
      {bool isTheme = false}) {
    final double imageSize = isTheme ? 120 : 100;
    final double containerHeight = isTheme ? 180 : 160;

    return SizedBox(
      height: containerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          final label = labels[index];
          final imagePath = _getImagePathByLabel(label);
          return GestureDetector(
            onTap: () {
              if (label == '서울') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SeoulPage()),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: imageSize,
              child: Column(
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getImagePathByLabel(String label) {
    switch (label) {
      case '서울':
        return 'assets/seoul.jpg';
      case '경기':
        return 'assets/gi.jpg';
      case '부산':
        return 'assets/busan.jpg';
      case '인천':
        return 'assets/incheon.jpg';
      case '감성 카페':
        return 'assets/caffee.jpg';
      case '연인과 걷기 좋은 장소':
        return 'assets/walk.jpg';
      case '인생 포토존':
        return 'assets/photo.jpg';
      default:
        return 'assets/sample.jpg';
    }
  }

  Widget _buildPopularCourse() {
    final PageController controller = PageController(viewportFraction: 0.9);
    final ValueNotifier<int> currentPage = ValueNotifier(0);

    final titles = ['동국대', '연세대', '홍익대'];
    final images = ['dongguk1.jpg', 'yonsei.jpg', 'hongik.jpg'];
    final desc = ['남산둘레길 · 7.3km', '신촌 데이트길 · 2.5km', '홍대 벽화길 · 1.8km'];

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: controller,
            itemCount: titles.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/${images[index]}',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          titles[index],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(desc[index]),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.favorite_border),
                          Icon(Icons.bookmark_border),
                          Icon(Icons.share),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: currentPage,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(titles.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: value == index ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: value == index ? Colors.deepPurple : Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

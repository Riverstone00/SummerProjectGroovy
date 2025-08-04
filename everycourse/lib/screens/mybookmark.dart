import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 1. 앱 시작
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookmarkedCoursesPage(),
    );
  }
}

// 2. Course 모델
class Course {
  final String title;
  final String location;
  final String imageUrl;
  final String priceTag;
  final String timeTag;
  final int likes;
  final int shares;
  final String description;

  Course({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.priceTag,
    required this.timeTag,
    required this.likes,
    required this.shares,
    required this.description,
  });
}

// 3. 샘플 북마크 데이터
List<Course> allCourses = [
  Course(
    title: '홍대에서 하루 쓰기',
    location: '서울 (홍익대)',
    imageUrl: 'https://cdn.pixabay.com/photo/2021/10/15/07/59/cafe-6710019_1280.jpg',
    priceTag: '1만원 이하',
    timeTag: '1일',
    likes: 8,
    shares: 2,
    description: '홍대 놀거리, 맛집, 책방 등을 하루 코스로 담았습니다!',
  ),
  Course(
    title: '날씨 좋은 봄, 동대냥이와 함께',
    location: '동국대학교, 팔정도',
    imageUrl: 'https://cdn.pixabay.com/photo/2017/03/27/13/56/cat-2170497_1280.jpg',
    priceTag: '5만원 이하',
    timeTag: '3.5시간',
    likes: 152,
    shares: 12,
    description: '동국대 마스코트 고양이와 함께 저녁 오코노미야끼!',
  ),
];

// 북마크된 코스 Set
Set<Course> bookmarkedCourses = {...allCourses};

class BookmarkedCoursesPage extends StatefulWidget {
  const BookmarkedCoursesPage({super.key});

  @override
  State<BookmarkedCoursesPage> createState() => _BookmarkedCoursesPageState();
}

class _BookmarkedCoursesPageState extends State<BookmarkedCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크한 코스'),
        backgroundColor: Colors.pink,
      ),
      body: bookmarkedCourses.isEmpty
          ? const Center(child: Text('북마크한 코스가 없습니다.'))
          : ListView.builder(
        itemCount: bookmarkedCourses.length,
        itemBuilder: (context, index) {
          final course = bookmarkedCourses.elementAt(index);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailPage(course: course),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(
                        course.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.location,
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(course.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _tagChip(Icons.attach_money, course.priceTag),
                                const SizedBox(width: 5),
                                _tagChip(Icons.access_time, course.timeTag),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _iconWithText(Icons.favorite_border, course.likes),
                                const SizedBox(width: 12),
                                _bookmarkToggleIcon(course),
                                const SizedBox(width: 12),
                                _iconWithText(Icons.share, course.shares),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bookmarkToggleIcon(Course course) {
    final isBookmarked = bookmarkedCourses.contains(course);
    return InkWell(
      onTap: () {
        setState(() {
          if (isBookmarked) {
            bookmarkedCourses.remove(course);
          } else {
            bookmarkedCourses.add(course);
          }
        });
      },
      child: Row(
        children: [
          Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: 16,
            color: isBookmarked ? Colors.pink : Colors.grey,
          ),
          const SizedBox(width: 2),
          Text('${isBookmarked ? '1' : '0'}', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _tagChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.pink),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.pink)),
        ],
      ),
    );
  }

  Widget _iconWithText(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 2),
        Text('$count', style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Image.network(course.imageUrl, height: 250, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.location, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(course.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

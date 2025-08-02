import 'package:flutter/material.dart';
import 'CourseDetail.dart';

class CourseList extends StatefulWidget {
  final String universityName;
  const CourseList({super.key, required this.universityName});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  String? selectedFilter;

  final List<Map<String, dynamic>> dummyCourses = [
    {
      "title": "날씨 좋은 봄, 동대냥이와 함께",
      "location": "동국대학교",
      "price": "5만원 이하",
      "time": "3.5시간",
      "image": "assets/images/test.jpg"
    },
    {
      "title": "취하고 싶은 하루",
      "location": "코스터",
      "price": "10만원 이하",
      "time": "4시간",
      "image": "assets/course2.jpg"
    },
    {
      "title": "도심 속 힐링, 한적한 하루",
      "location": "남산 산책로",
      "price": "3만원 이하",
      "time": "3.5시간",
      "image": "assets/course3.jpg"
    },
    {
      "title": "꽁냥 시간, 맛집 데이트",
      "location": "종각 근처",
      "price": "5만원 이하",
      "time": "3시간",
      "image": "assets/course4.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCourses = selectedFilter == null
        ? dummyCourses
        : dummyCourses.where((course) => course['price'] == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.universityName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
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
                  return GestureDetector(
                    onTap: () {
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
                          child: Image.asset(
                            course['image'],
                            width: double.infinity,
                            height: 135,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 135,
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          course['location'],
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "💰 ${course['price']}  ⏱️ ${course['time']}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
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

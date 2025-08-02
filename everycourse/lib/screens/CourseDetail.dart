import 'package:flutter/material.dart';

class CourseDetail extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetail({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F5),
      appBar: AppBar(
        title: const Text(''), // 제목 제거
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 대표 이미지
            Image.asset(
              course['image'],
              width: double.infinity,
              height: 260, // 더 길게
              fit: BoxFit.cover,
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                course['title'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // 별점 + 가격/시간
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.red, size: 20),
                  const Icon(Icons.star, color: Colors.red, size: 20),
                  const Icon(Icons.star, color: Colors.red, size: 20),
                  const Icon(Icons.star_half, color: Colors.red, size: 20),
                  const Icon(Icons.star_border, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Text('152 (4.4/5)', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text("💰", style: TextStyle(fontSize: 14)),
                  Text(" ${course['price']}  ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const Text("⏱️", style: TextStyle(fontSize: 14)),
                  Text(" ${course['time']}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),

            // 설명
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                '동국대의 마스코트 동국냥이와 함께하는 시간. 서울에서 경험하기 힘든 포메와 저녁에 오코노미야끼에 하이볼까지..!',
                style: TextStyle(fontSize: 15),
              ),
            ),

            // 해시태그
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                children: [
                  '#고양이', '#동국대', '#지니로드', '#오코노미야끼'
                ].map((tag) => Text(tag, style: const TextStyle(color: Colors.grey, fontSize: 13))).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 장소 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildPlaceButton('동국대학교, 팔정도'),
                  const SizedBox(height: 8),
                  _buildPlaceButton('키노이에(きのいえ)'),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 장소 버튼 위젯
  Widget _buildPlaceButton(String name) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.place_outlined),
        label: Text(name, style: const TextStyle(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF49CA2),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {},
      ),
    );
  }
}

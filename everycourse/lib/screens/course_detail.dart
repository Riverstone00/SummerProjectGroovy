import 'package:flutter/material.dart';
import 'package:everycourse/services/course_service.dart';

class CourseDetail extends StatelessWidget {
  final Map<String, dynamic> course;
  final CourseService _courseService = CourseService();

  CourseDetail({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // 가격과 시간 정보 포맷
    final formatInfo = _courseService.formatPriceAndTime(course);
    final formattedPrice = formatInfo['formattedPrice'] ?? '가격 정보 없음';
    final formattedTime = formatInfo['formattedTime'] ?? '시간 정보 없음';
    
    // 해시태그 처리
    final List<String> hashtags = [];
    if (course['hashtags'] != null) {
      if (course['hashtags'] is List) {
        hashtags.addAll((course['hashtags'] as List).map((tag) => '#$tag').toList());
      }
    }

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
            Builder(
              builder: (context) {
                String? imageUrl = course['imageUrl'];
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  return Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('상세 이미지 로드 오류($imageUrl): $error');
                      return Image.asset(
                        'assets/images/course1.png',
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                } else {
                  return Image.asset(
                    'assets/images/course1.png',
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  );
                }
              },
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                course['title'] ?? '제목 없음',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // 별점
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRatingStars(course['rating']),
                  const SizedBox(width: 6),
                  Text(
                    course['reviewCount'] != null 
                        ? '${course['reviewCount']} (${(course['rating'] as num?)?.toStringAsFixed(1) ?? '0.0'}/10)' 
                        : '0 (0.0/10)',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14)
                  ),
                ],
              ),
            ),

            // 가격 및 시간
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text("💰", style: TextStyle(fontSize: 14)),
                  Text(" $formattedPrice  ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const Text("⏱️", style: TextStyle(fontSize: 14)),
                  Text(" $formattedTime", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),

            // 설명
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                course['description'] ?? '설명이 없습니다.',
                style: const TextStyle(fontSize: 15),
              ),
            ),

            // 해시태그
            if (hashtags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: hashtags
                      .map((tag) => Text(tag, style: const TextStyle(color: Colors.grey, fontSize: 13)))
                      .toList(),
                ),
              ),

            const SizedBox(height: 20),

            // 장소 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (course['location'] != null)
                    _buildPlaceButton(course['location']),
                  if (course['place'] != null && course['place'] != course['location'])
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildPlaceButton(course['place']),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 별점 표시 위젯
  Widget _buildRatingStars(dynamic rating) {
    double ratingValue = 0;
    if (rating != null) {
      if (rating is num) {
        ratingValue = rating.toDouble();
      }
    }
    
    // 10점 만점을 5점 척도로 변환
    ratingValue = ratingValue / 2;
    
    List<Widget> stars = [];
    
    // 전체 별 아이콘 생성
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      Color color = Colors.amber;
      
      if (i <= ratingValue) {
        iconData = Icons.star; // 꽉 찬 별
      } else if (i > ratingValue && i <= ratingValue + 0.5) {
        iconData = Icons.star_half; // 반 별
      } else {
        iconData = Icons.star_border; // 빈 별
      }
      
      stars.add(Icon(iconData, color: color, size: 20));
    }
    
    return Row(children: stars);
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

import 'package:flutter/material.dart';
import 'CourseList.dart'; // 코스 리스트 페이지 import

class SeoulPage extends StatelessWidget {
  const SeoulPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> universities = [
      {
        "name": "동국대학교",
        "rating": 4.7,
        "review": 512,
        "desc": "남산 자락에 위치한 전통과 현대가 어우러진 캠퍼스. 도심 속에서도 조용하고 여유로운 분위기를 느낄 수 있어요.",
        "image": "assets/images/dongguk2.jpg",
      },
      {
        "name": "연세대학교",
        "rating": 4.4,
        "review": 272,
        "desc": "신촌의 위치로 복잡하지만 분위기 좋고 산책도 가능.",
        "image": "assets/images/yonsei.jpg",
      },
      {
        "name": "홍익대학교",
        "rating": 4.6,
        "review": 365,
        "desc": "예술적인 감성이 가득한 캠퍼스. 개성있는 데이트 코스로 추천.",
        "image": "assets/images/honggik.jpg",
      },
      {
        "name": "성균관대학교",
        "rating": 4.8,
        "review": 272,
        "desc": "조용하고 전통이 있는 분위기. 조경이 잘 되어 있어 여유롭게 걷기 좋아요.",
        "image": "assets/images/sung.jpg",
      },
      {
        "name": "건국대학교",
        "rating": 4.8,
        "review": 783,
        "desc": "호수와 캠퍼스가 어우러져 분위기 최고! 넓고 쾌적한 캠퍼스로 산책 코스로 추천.",
        "image": "assets/imgaes/konkuk.jpg",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('서울'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.separated(
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
                    child: Image.asset(
                      u['image'],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300]),
                    ),
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
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.star,
                                color: Colors.orange, size: 16),
                            Text('${u["rating"]}'),
                            const Spacer(),
                            Text(
                              '(${u["review"]})',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          u['desc'],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
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
}

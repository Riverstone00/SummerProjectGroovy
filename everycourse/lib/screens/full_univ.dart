import 'package:flutter/material.dart';
import 'region_page.dart'; // RegionPage import
import 'seoul_page.dart'; // SeoulPage import

// 지역 카드 데이터 클래스
class RegionCardData {
  final String id;
  final String title;
  final String imageUrl;
  final Color accent;
  const RegionCardData({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.accent,
  });
}

// 지역 데이터 리스트
const List<RegionCardData> regions = [
  RegionCardData(
    id: 'seoul',
    title: '서울',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fseoul.jpg?alt=media&token=cece7482-0b0c-4527-a0f2-968bb4d587fb',
    accent: Color(0xFFDCCCDC),
  ),
  RegionCardData(
    id: 'gyeonggi',
    title: '경기',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fgi.jpg?alt=media&token=a9f7b2c5-bddf-4fb1-a41f-56d5649453e1',
    accent: Color(0xFFFFF3E8),
  ),
  RegionCardData(
    id: 'incheon',
    title: '인천',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fincheon.jpg?alt=media&token=495ff287-b8c1-4424-9521-c28337de19f7',
    accent: Color(0xFFE3EDF7),
  ),
  RegionCardData(
    id: 'daejeon',
    title: '대전',
    imageUrl:
        'https://i.namu.wiki/i/AMQ1MIi_OZZM3Mu8WH5l1EHQHcavfGutNtUm9Jl8KgIxIW7teJL83lc1X94h9-RuTcQi3pKmYPC8xiR0qZAFAQ.webp',
    accent: Color(0xFFD7EDE3),
  ),
  RegionCardData(
    id: 'daegu',
    title: '대구',
    imageUrl:
        'https://pimg.mk.co.kr/meet/neds/2022/02/image_readtop_2022_179467_16457293214956350.jpg',
    accent: Color(0xFFFFEFD9),
  ),
  RegionCardData(
    id: 'busan',
    title: '부산',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/everycourse-911af.firebasestorage.app/o/images%2Fbusan.jpg?alt=media&token=ce16af8f-2a5a-4926-a6d4-07b8a7c5caa8',
    accent: Color(0xFFE6F1F7),
  ),
  RegionCardData(
    id: 'gwangju',
    title: '광주',
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTM_rxaeZokBDvKvZ0ESm8NVK77bsjlv2_VYg&s',
    accent: Color(0xFFD9F2E2),
  ),
  RegionCardData(
    id: 'ulsan',
    title: '울산',
    imageUrl:
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/07/e9/e4/13/daewangam-park.jpg?w=1200&h=700&s=1',
    accent: Color(0xFFFCE4EC),
  ),
];

// 메인 위젯
class FullUnivPage extends StatelessWidget {
  const FullUnivPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '대학생의 숨은 데이트 코스 전체',
          style: TextStyle(fontFamily: 'Cafe24Ssurround'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: regions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 0,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, i) {
            final data = regions[i];
            return RegionTiltCard(
              data: data,
              tiltAngle: -0.06,
              onTap: () {
                if (data.id == 'seoul') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SeoulPage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RegionPage(regionId: data.id, regionName: data.title),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

// 카드 위젯
class RegionTiltCard extends StatelessWidget {
  final RegionCardData data;
  final double tiltAngle;
  final VoidCallback? onTap;

  const RegionTiltCard({
    super.key,
    required this.data,
    this.tiltAngle = -0.06,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final boxW = c.maxWidth * 0.9;
        final boxH = c.maxHeight * 0.6;
        const offsetY = 8.0;

        return InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 파스텔 배경 박스
              Container(width: boxW, height: boxH, color: data.accent),

              // 하얀 박스(살짝 기울이고, 그 안에 사진+이름)
              Transform.translate(
                offset: const Offset(0, offsetY),
                child: Transform.rotate(
                  angle: tiltAngle,
                  child: Container(
                    width: boxW,
                    height: boxH,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // 아래로 정렬
                      children: [
                        const SizedBox(height: 10), // 사진을 조금 밑으로 내리는 여백
                        // 사진이 들어가는 박스
                        Container(
                          width: boxW * 0.85,
                          height: boxH * 0.62,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: NetworkImage(data.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), // 사진과 구분선 사이 간격
                        // 지역명
                        Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: 'Cafe24Ssurround',
                          ),
                        ),
                        const SizedBox(height: 10), // 카드 하단 여백
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

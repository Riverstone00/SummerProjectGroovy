// full_course.dart
import 'package:flutter/material.dart';

class FullCoursePage extends StatelessWidget {
  const FullCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 카드 데이터 (연인과 걷기 좋은 장소만 12, 나머지 13)
    const themesRow1 = [
      ThemeCardData(
        '감성 카페',
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
      ThemeCardData(
        '연인과 걷기 좋은 장소',
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 12,
      ),
    ];

    const themesRow2 = [
      ThemeCardData(
        '야경 명소',
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
      ThemeCardData(
        '전시·문화생활',
        'https://images.unsplash.com/photo-1496317899792-9d7dbcd928a1',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
      ThemeCardData(
        '숨겨진 여행지',
        'https://images.unsplash.com/photo-1440404653325-ab127d49abc1',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
    ];

    const themesRow3 = [
      ThemeCardData(
        '맛집 탐방',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
      ThemeCardData(
        '데이트 명소',
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
      ThemeCardData(
        '힐링 코스',
        'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
        fontFamily: 'Cafe24Ssurround',
        fontSize: 13,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '테마별 코스 전체 보기',
          style: TextStyle(
            fontFamily: 'Cafe24Ssurround',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: const [
          GarlandRowFlexible(
            items: themesRow1,
            rowHeight: 186,
            startYRatio: 0.05,
            endYRatio: 0.16,
            sagPx: 8,
            verticalHang: 16,
            rotations: [-8, 6],
          ),
          SizedBox(height: 16),
          GarlandRowFlexible(
            items: themesRow2,
            rowHeight: 192,
            startYRatio: 0.22,
            endYRatio: 0.13,
            sagPx: 6,
            verticalHang: 16,
            rotations: [-5, 4, -6],
          ),
          SizedBox(height: 16),
          GarlandRowFlexible(
            items: themesRow3,
            rowHeight: 192,
            startYRatio: 0.36,
            endYRatio: 0.48,
            sagPx: 8,
            verticalHang: 16,
            rotations: [-7, 5, -4],
          ),
        ],
      ),
    );
  }
}

/* ===== 데이터 ===== */
class ThemeCardData {
  final String title;
  final String imageUrl;
  final String? fontFamily;
  final double fontSize; // 카드별 폰트 크기
  const ThemeCardData(
    this.title,
    this.imageUrl, {
    this.fontFamily,
    this.fontSize = 13,
  });
}

/* ===== 가랜드(대각선 + 살짝 처짐) ===== */
class GarlandRowFlexible extends StatelessWidget {
  final List<ThemeCardData> items;
  final double rowHeight;
  final double startYRatio;
  final double endYRatio;
  final double sagPx;
  final List<double> rotations;
  final double verticalHang;
  final double ropeThickness;

  const GarlandRowFlexible({
    super.key,
    required this.items,
    this.rowHeight = 186,
    required this.startYRatio,
    required this.endYRatio,
    this.sagPx = 6,
    this.rotations = const [],
    this.verticalHang = 16,
    this.ropeThickness = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final y0 = h * startYRatio;
          final y1 = h * endYRatio;

          // 균등 간격 배치 + 특정 카드 미세 보정
          final ts = List<double>.generate(items.length, (i) {
            final step = 1 / (items.length + 1);
            double t = step * (i + 1);

            // 👇 "야경 명소" 왼쪽으로 이동
            if (items[i].title == '야경 명소') {
              t -= 0.05;
            }

            // 👇 "숨겨진 여행지" 오른쪽으로 이동
            if (items[i].title == '숨겨진 여행지') {
              t += 0.05;
            }

            // 화면 밖으로 안 나가게 클램프
            if (t < 0.08) t = 0.08;
            if (t > 0.92) t = 0.92;
            return t;
          });

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(w, h),
                painter: _SagRopePainter(
                  y0: y0,
                  y1: y1,
                  sag: sagPx,
                  thickness: ropeThickness,
                ),
              ),
              for (int i = 0; i < items.length; i++)
                ..._buildHanging(
                  data: items[i],
                  width: w,
                  t: ts[i],
                  y0: y0,
                  y1: y1,
                  sag: sagPx,
                  rotationDeg: (i < rotations.length) ? rotations[i] : 0,
                ),
            ],
          );
        },
      ),
    );
  }

  double _ropeY(double t, double y0, double y1, double sag) {
    final p0y = y0;
    final p1y = (y0 + y1) / 2 + sag;
    final p2y = y1;
    final one = (1 - t);
    return one * one * p0y + 2 * one * t * p1y + t * t * p2y;
  }

  List<Widget> _buildHanging({
    required ThemeCardData data,
    required double width,
    required double t,
    required double y0,
    required double y1,
    required double sag,
    required double rotationDeg,
  }) {
    const cardSize = Size(128, 140);
    final x = width * t;
    final ropeY = _ropeY(t, y0, y1, sag);
    final radians = rotationDeg * 3.1415926535 / 180;

    return [
      // 실
      Positioned(
        left: x - 1,
        top: ropeY + 2,
        child: Container(
          width: 2,
          height: verticalHang - 2,
          decoration: BoxDecoration(
            color: const Color(0xFFB09774).withOpacity(0.9),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
      // 핀 + 카드
      Positioned(
        left: x - cardSize.width / 2,
        top: ropeY + verticalHang,
        child: Column(
          children: [
            Transform.rotate(
              angle: radians / 3,
              child: Container(
                width: 12,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9A86C),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Transform.rotate(
              angle: radians,
              child: _PolaroidCard(
                title: data.title,
                imageUrl: data.imageUrl,
                size: cardSize,
                fontFamily: data.fontFamily,
                fontSize: data.fontSize,
                titleMaxLines: 2,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/* ===== 줄 Painter ===== */
class _SagRopePainter extends CustomPainter {
  final double y0, y1, sag, thickness;
  const _SagRopePainter({
    required this.y0,
    required this.y1,
    required this.sag,
    this.thickness = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midX = size.width / 2;
    final p0 = Offset(0, y0);
    final p1 = Offset(midX, (y0 + y1) / 2 + sag);
    final p2 = Offset(size.width, y1);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    final paintRope = Paint()
      ..color = const Color(0xFFB09774)
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 3, false);
    canvas.drawPath(path, paintRope);
  }

  @override
  bool shouldRepaint(covariant _SagRopePainter old) =>
      old.y0 != y0 ||
      old.y1 != y1 ||
      old.sag != sag ||
      old.thickness != thickness;
}

/* ===== 폴라로이드 카드 ===== */
class _PolaroidCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Size size;
  final String? fontFamily;
  final double fontSize;
  final int titleMaxLines;

  const _PolaroidCard({
    required this.title,
    required this.imageUrl,
    required this.size,
    this.fontFamily,
    this.fontSize = 13,
    this.titleMaxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium;
    final textStyle = (fontFamily == null)
        ? base?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: fontSize,
          )
        : base?.copyWith(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: fontSize,
          );

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0.5,
            offset: Offset(0, 5),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: textStyle,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

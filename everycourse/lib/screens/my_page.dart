import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'My Page',
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.pink.shade100,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        '동국',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      Icon(Icons.female, color: Colors.red, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag('인증✔', Colors.grey.shade50),
                      const SizedBox(width: 4),
                      _buildTag('2002.2.2', Colors.grey.shade100),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('계정'),
          _buildMenuItem('아이디'),
          _buildMenuItem('비밀번호 변경'),
          _buildMenuItem('계정 인증'),
          _buildMenuItem('로그아웃'),
          _buildDivider(),
          _buildSectionTitle('코스 관리'),
          _buildMenuItem('코스 올리기'),
          _buildMenuItem('내가 등록한 코스'),
          _buildMenuItem('리뷰(평점)'),
          _buildDivider(),
          _buildSectionTitle('북마크'),
          _buildMenuItem('북마크한 코스'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.pink, offset: Offset(0, 0))],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Colors.pinkAccent, thickness: 0.5);
  }
}

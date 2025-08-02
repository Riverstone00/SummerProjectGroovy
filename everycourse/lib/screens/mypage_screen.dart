import 'package:flutter/material.dart';


class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 예시 데이터 (실제 앱에서는 사용자 정보/인증 여부를 Provider 등으로 관리)
    final String userName = '홍길동';
    final String profileImageUrl = '';
    final bool isStudentVerified = true;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // 프로필 영역
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 48, color: Color(0xFFD391FF))
                            : null,
                      ),
                      if (isStudentVerified)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFF4047FF), width: 2),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.verified, color: Color(0xFF4047FF), size: 24),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD391FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 설정 리스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account',
                      style: TextStyle(
                        color: Color(0xFFFEBDBD),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Color(0xFFD391FF)),
                    title: const Text('User ID', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: Color(0xFFD391FF)),
                    title: const Text('Change password', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                  const Text('Support',
                      style: TextStyle(
                        color: Color(0xFFFFBEBE),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Color(0xFFD391FF)),
                    title: const Text('FAQ', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.campaign_outlined, color: Color(0xFFD391FF)),
                    title: const Text('Notice', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFFD391FF)),
                    title: const Text('Privacy policy', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.article_outlined, color: Color(0xFFD391FF)),
                    title: const Text('Terms of service', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

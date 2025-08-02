import 'package:flutter/material.dart';
import 'package:everycourse/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final UserService _userService = UserService();
  String userName = '사용자';
  String profileImageUrl = '';
  bool isStudentVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 사용자 프로필 정보 로드
  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Firestore에서 사용자 프로필 정보 가져오기
      final userProfile = await _userService.getCurrentUserProfile();
      
      if (userProfile != null && userProfile.exists) {
        final data = userProfile.data() as Map<String, dynamic>?;
        
        setState(() {
          userName = data?['displayName'] ?? user.displayName ?? '사용자';
          profileImageUrl = data?['photoURL'] ?? user.photoURL ?? '';
          isStudentVerified = data?['isStudentVerified'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          userName = user.displayName ?? '사용자';
          profileImageUrl = user.photoURL ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD391FF),
                ),
              )
            : Column(
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
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFD391FF)),
                    title: const Text('로그아웃', style: TextStyle(color: Color(0xFFD391FF))),
                    onTap: () async {
                      // 로그아웃 확인 다이얼로그 표시
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말 로그아웃 하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('로그아웃'),
                            ),
                          ],
                        ),
                      );
                      
                      // 사용자가 확인을 선택하면 로그아웃 실행
                      if (confirm == true) {
                        try {
                          final userService = UserService();
                          await userService.signOut();
                          
                          // 로그아웃 후 인증 상태가 변경되어 자동으로 AuthScreen으로 이동됩니다
                          // 추가적인 네비게이션 처리는 필요하지 않습니다
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('로그아웃 되었습니다')),
                          );
                        } catch (e) {
                          // 로그아웃 실패 시 오류 메시지 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그아웃 실패: $e')),
                          );
                        }
                      }
                    },
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

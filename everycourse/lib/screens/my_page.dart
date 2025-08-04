import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:everycourse/services/user_service.dart';
import 'package:everycourse/screens/bookmarked_courses.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
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
    // 현재 로그인한 사용자 확인
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FB),
        elevation: 0,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.pink.shade100,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
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
                            isStudentVerified
                                ? _buildTag('인증✔', Colors.grey.shade50)
                                : _buildTag('미인증', Colors.grey.shade50),
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
          _buildMenuItem('로그아웃', onTap: () async {
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
                await _userService.signOut();
                // 로그아웃 후 알림 표시
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그아웃 되었습니다')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그아웃 실패: $e')),
                  );
                }
              }
            }
          }),
          _buildDivider(),
          _buildSectionTitle('코스 관리'),
          _buildMenuItem('코스 올리기'),
          _buildMenuItem('내가 등록한 코스'),
          _buildMenuItem('리뷰(평점)'),
          _buildDivider(),
          _buildSectionTitle('북마크'),
          _buildMenuItem('북마크한 코스', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookmarkedCoursesPage(),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
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

  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Colors.pinkAccent, thickness: 0.5);
  }
}

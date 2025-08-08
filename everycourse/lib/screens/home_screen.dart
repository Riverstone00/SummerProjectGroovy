import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../services/course_post_service.dart';
import 'explore_screen.dart';
import 'feed_screen.dart';
import 'my_page.dart';
import 'write_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  
  // 게시물 목록
  final List<Post> _posts = [];
  final CoursePostService _courseService = CoursePostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  
  // FeedScreen에 접근하기 위한 GlobalKey
  final GlobalKey<FeedScreenState> _feedScreenKey = GlobalKey<FeedScreenState>();
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
    // 앱 라이프사이클 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 앱 라이프사이클 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 다시 활성화될 때 FeedScreen 새로고침
    if (state == AppLifecycleState.resumed && _selectedIndex == 1) {
      _feedScreenKey.currentState?.refreshStudentVerification();
    }
  }
  
  // Firebase에서 로그인한 유저의 게시물 불러오기
  Future<void> _loadPosts() async {
    if (_isLoading) return;
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('로그인된 사용자가 없습니다.');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _courseService.getUserCourses(currentUser.uid);
      setState(() {
        _posts.clear();
        _posts.addAll(posts);
      });
    } catch (e) {
      print('코스 불러오기 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('코스를 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 게시물 삭제
  Future<void> _deletePost(Post post) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시물을 삭제 중입니다...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      await _courseService.deleteCourse(post.id, currentUser.uid);
      await _loadPosts(); // 목록 새로고침

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시물이 성공적으로 삭제되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시물 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('게시물 삭제 오류: $e');
    }
  }
  void _navigateToWriteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteScreen(
          onAdd: (post) async {
            try {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('코스를 저장 중입니다...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
              
              await _courseService.addCourse(post, _auth.currentUser!.uid);
              await _loadPosts();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('코스가 성공적으로 등록되었습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('코스 저장 중 오류가 발생했습니다: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              print('코스 저장 오류: $e');
            }
          },
        ),
      ),
    );
  }

  // 화면 목록
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const ExploreScreen();
      case 1:
        return FeedScreen(
          key: _feedScreenKey,
          posts: _posts, 
          onWritePressed: _navigateToWriteScreen,
          onDeletePost: _deletePost,
        );
      case 2:
        return MyPage(onTabChanged: _onItemTapped);
      default:
        return const ExploreScreen();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // 게시 탭으로 전환할 때 학생 인증 상태 새로고침
    if (index == 1) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _feedScreenKey.currentState?.refreshStudentVerification();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '탐색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '게시',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
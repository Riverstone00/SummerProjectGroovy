import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_item.dart';
import '../services/student_verification_service.dart';
import 'course_detail.dart';

class FeedScreen extends StatefulWidget {
  final List<Post> posts;
  final VoidCallback onWritePressed;
  final Function(Post)? onDeletePost;
  
  const FeedScreen({
    super.key, 
    required this.posts, 
    required this.onWritePressed,
    this.onDeletePost,
  });

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  final StudentVerificationService _verificationService = StudentVerificationService();
  bool _isVerifiedStudent = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStudentVerification();
  }

  Future<void> _checkStudentVerification() async {
    try {
      final isVerified = await _verificationService.isVerifiedStudent();
      setState(() {
        _isVerifiedStudent = isVerified;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking student verification: $e');
      setState(() {
        _isVerifiedStudent = false;
        _isLoading = false;
      });
    }
  }

  // 외부에서 호출할 수 있는 새로고침 메소드
  Future<void> refreshStudentVerification() async {
    await _checkStudentVerification();
  }

  void _navigateToCourseDetail(BuildContext context, Post post) {
    // Post를 Map<String, dynamic> 형태로 변환
    final courseData = {
      'courseId': post.id,
      'id': post.id,
      'title': post.title,
      'description': post.content ?? '설명이 없습니다.',
      'image': post.imageUrl, // course_detail에서 사용하는 키명
      'imageUrl': post.imageUrl, // 백업용으로 둘 다 포함
      'hashtags': post.hashtags ?? [],
      'priceAmount': post.priceAmount ?? 0,
      'timeMinutes': post.timeMinutes ?? 0,
      'places': post.places ?? [],
      'location': post.location,
      // CourseDetail에서 필요한 다른 필드들
      'rating': post.rating,
      'reviewCount': post.reviewCount,
      'likes': post.likes,
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetail(course: courseData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: widget.posts.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 게시글이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isVerifiedStudent 
                        ? '우측 하단 + 버튼을 눌러 게시글을 작성해보세요!'
                        : '마이페이지에서 학생 인증을 해 주세요',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.posts.length,
              itemBuilder: (ctx, i) => PostItem(
                post: widget.posts[i],
                onTap: () => _navigateToCourseDetail(context, widget.posts[i]),
                onDelete: widget.onDeletePost != null ? () => widget.onDeletePost!(widget.posts[i]) : null,
              ),
            ),
        floatingActionButton: _isVerifiedStudent ? FloatingActionButton(
          onPressed: () {
            print('+ 버튼이 눌렸습니다!');
            print('Navigator 호출을 시작합니다.');
            widget.onWritePressed();
          },
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ) : null, // 학생 인증이 안 된 경우 null로 설정하여 버튼 숨김
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_item.dart';
import 'course_detail.dart';

class FeedScreen extends StatelessWidget {
  final List<Post> posts;
  final VoidCallback onWritePressed;
  final Function(Post)? onDeletePost;
  
  const FeedScreen({
    super.key, 
    required this.posts, 
    required this.onWritePressed,
    this.onDeletePost,
  });

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
    return Scaffold(
      body: posts.isEmpty 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '등록된 게시글이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '우측 하단 + 버튼을 눌러 게시글을 작성해보세요!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (ctx, i) => PostItem(
                post: posts[i],
                onTap: () => _navigateToCourseDetail(context, posts[i]),
                onDelete: onDeletePost != null ? () => onDeletePost!(posts[i]) : null,
              ),
            ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('+ 버튼이 눌렸습니다!');
            print('Navigator 호출을 시작합니다.');
            onWritePressed();
          },
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

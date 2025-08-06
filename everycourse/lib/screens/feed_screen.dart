// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_item.dart';

class FeedScreen extends StatelessWidget {
  final List<Post> posts;
  final VoidCallback onWritePressed;
  
  const FeedScreen({
    super.key, 
    required this.posts, 
    required this.onWritePressed
  });

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
              itemBuilder: (ctx, i) => PostItem(post: posts[i]),
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

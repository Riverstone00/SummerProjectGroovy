// lib/widgets/post_item.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostItem extends StatelessWidget {
  final Post post;
  
  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: _buildImage(),
            ),
          ),
          
          // 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // 태그 목록
                if (post.tags != null && post.tags!.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: post.tags!.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.pink.shade50,
                      labelStyle: TextStyle(color: Colors.pink.shade700),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                
                const SizedBox(height: 8),
                
                // 가격 및 소요시간
                Row(
                  children: [
                    if (post.price != null) ...[
                      Icon(Icons.payments_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        post.price!,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    if (post.duration != null) ...[
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        post.duration!,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
                
                // 내용 (선택적)
                if (post.content != null && post.content!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    post.content!,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Firebase Storage 이미지 URL이 있는 경우 우선 사용
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return Image.network(
        post.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('네트워크 이미지 로드 오류(${post.imageUrl}): $error');
          // 네트워크 이미지 실패 시 로컬 이미지로 fallback
          return _buildLocalImage();
        },
      );
    }
    // 로컬 이미지 처리
    else {
      return _buildLocalImage();
    }
  }

  Widget _buildLocalImage() {
    if (kIsWeb && post.webImageBytes != null) {
      return Image.memory(
        post.webImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('웹 이미지 로드 오류: $error');
          return _buildFallbackImage();
        },
      );
    } else if (!kIsWeb && post.imagePath != null) {
      return Image.file(
        File(post.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('파일 이미지 로드 오류(${post.imagePath}): $error');
          return _buildFallbackImage();
        },
      );
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    // course_list처럼 여러 대체 이미지 중 하나 선택
    final List<String> fallbackImages = [
      'assets/images/course1.png',
      'assets/images/course2.png', 
      'assets/images/course3.png',
      'assets/images/course4.png',
      'assets/images/nothing.png',
    ];
    
    // 포스트 제목의 해시코드를 이용해 일관된 이미지 선택
    int imageIndex = post.title.hashCode % fallbackImages.length;
    if (imageIndex < 0) imageIndex = -imageIndex; // 음수 방지
    
    return Image.asset(
      fallbackImages[imageIndex],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('대체 이미지 로드 오류(${fallbackImages[imageIndex]}): $error');
        // 최후의 수단으로 컨테이너 표시
        return Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}

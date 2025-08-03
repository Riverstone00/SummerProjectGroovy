// lib/models/post.dart
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final String? imagePath;
  final String title;
  final String? price;
  final String? duration;
  final String? content;          // 내용 저장용
  final List<String>? tags;

  Post({
    String? id,
    this.imagePath,
    required this.title,
    this.price,
    this.duration,
    this.content,                 // constructor에 추가
    this.tags,
  }) : id = id ?? const Uuid().v4();
}

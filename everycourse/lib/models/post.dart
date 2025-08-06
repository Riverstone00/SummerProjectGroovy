// lib/models/post.dart

import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final String? imagePath;         // 모바일 파일경로
  final Uint8List? webImageBytes;  // 웹 바이트 데이터
  final String title;
  final String? price;
  final String? duration;
  final List<String>? tags;
  final String? content;

  Post({
    String? id,
    this.imagePath,
    this.webImageBytes,
    required this.title,
    this.price,
    this.duration,
    this.tags,
    this.content,
  }) : id = id ?? const Uuid().v4();
}

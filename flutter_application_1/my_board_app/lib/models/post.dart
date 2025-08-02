// lib/models/post.dart
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final String? imagePath;
  final String title;
  final String? price;
  final String? duration;

  Post({
    String? id,
    required this.imagePath,
    required this.title,
    this.price,
    this.duration,
  }) : id = id ?? const Uuid().v4();
}

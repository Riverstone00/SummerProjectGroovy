// lib/models/post.dart

import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final String? imagePath;         // 모바일 파일경로
  final Uint8List? webImageBytes;  // 웹 바이트 데이터
  final String? imageUrl;          // Firebase Storage URL
  final String title;
  final String? content;           // description으로도 사용
  final int? priceAmount;          // 가격 (원 단위)
  final int? timeMinutes;          // 소요시간 (분 단위)
  final List<String>? hashtags;    // 해시태그
  final List<String>? places;      // 장소 리스트
  final String? location;          // 메인 위치
  final double rating;             // 평점
  final int reviewCount;           // 리뷰 수
  final int likes;                 // 좋아요 수

  Post({
    String? id,
    this.imagePath,
    this.webImageBytes,
    this.imageUrl,
    required this.title,
    this.content,
    this.priceAmount,
    this.timeMinutes,
    this.hashtags,
    this.places,
    this.location,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.likes = 0,
  }) : id = id ?? const Uuid().v4();
}

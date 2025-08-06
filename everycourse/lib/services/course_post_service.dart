// lib/services/course_post_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';

class CoursePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // 모든 코스 가져오기
  Future<List<Post>> getAllCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'],
          priceAmount: data['priceAmount'],
          timeMinutes: data['timeMinutes'],
          hashtags: List<String>.from(data['hashtags'] ?? []),
          places: List<String>.from(data['places'] ?? []),
          location: data['location'],
          rating: (data['rating'] ?? 0.0).toDouble(),
          reviewCount: data['reviewCount'] ?? 0,
          likes: data['likes'] ?? 0,
          imageUrl: data['imageUrl'], // Firebase Storage URL
        );
      }).toList();
    } catch (e) {
      print('코스 불러오기 오류: $e');
      rethrow;
    }
  }
  
  // 새 코스 추가
  Future<void> addCourse(Post post, String userId) async {
    try {
      // 1. 이미지 업로드
      String? imageUrl;
      
      if (kIsWeb && post.webImageBytes != null) {
        // 웹: Uint8List 업로드
        final ref = _storage.ref().child('courses/${post.id}');
        final uploadTask = ref.putData(post.webImageBytes!);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } else if (!kIsWeb && post.imagePath != null) {
        // 모바일: File 업로드
        final ref = _storage.ref().child('courses/${post.id}');
        final uploadTask = ref.putFile(File(post.imagePath!));
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      
      // 2. Firestore에 데이터 저장
      await _firestore.collection('courses').doc(post.id).set({
        'userId': userId,
        'title': post.title,
        'content': post.content,
        'priceAmount': post.priceAmount,
        'timeMinutes': post.timeMinutes,
        'hashtags': post.hashtags,
        'places': post.places,
        'location': post.location,
        'rating': post.rating,
        'reviewCount': post.reviewCount,
        'likes': post.likes,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('코스 추가 오류: $e');
      rethrow;
    }
  }
  
  // 특정 사용자의 코스만 가져오기
  Future<List<Post>> getUserCourses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('userId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'],
          priceAmount: data['priceAmount'],
          timeMinutes: data['timeMinutes'],
          hashtags: List<String>.from(data['hashtags'] ?? []),
          places: List<String>.from(data['places'] ?? []),
          location: data['location'],
          rating: (data['rating'] ?? 0.0).toDouble(),
          reviewCount: data['reviewCount'] ?? 0,
          likes: data['likes'] ?? 0,
          imageUrl: data['imageUrl'], // Firebase Storage URL
        );
      }).toList();
    } catch (e) {
      print('사용자 코스 불러오기 오류: $e');
      rethrow;
    }
  }
  
  // 코스 삭제
  Future<void> deleteCourse(String courseId, String userId) async {
    try {
      // 1. Firestore에서 문서 삭제
      final docRef = _firestore.collection('courses').doc(courseId);
      
      // 삭제하기 전에 해당 사용자의 게시물인지 확인
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('삭제할 코스를 찾을 수 없습니다.');
      }
      
      final data = doc.data()!;
      if (data['userId'] != userId) {
        throw Exception('본인의 게시물만 삭제할 수 있습니다.');
      }
      
      // 2. Storage에서 이미지 삭제 (선택사항)
      try {
        final imageUrl = data['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      } catch (e) {
        print('이미지 삭제 오류 (무시): $e');
        // 이미지 삭제 실패는 무시하고 계속 진행
      }
      
      // 3. Firestore 문서 삭제
      await docRef.delete();
      
    } catch (e) {
      print('코스 삭제 오류: $e');
      rethrow;
    }
  }
}

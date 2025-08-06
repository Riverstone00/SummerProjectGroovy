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
          price: data['price'],
          duration: data['duration'],
          tags: List<String>.from(data['tags'] ?? []),
          content: data['content'],
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
        'price': post.price,
        'duration': post.duration,
        'tags': post.tags,
        'content': post.content,
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
          price: data['price'],
          duration: data['duration'],
          tags: List<String>.from(data['tags'] ?? []),
          content: data['content'],
          imageUrl: data['imageUrl'], // Firebase Storage URL
        );
      }).toList();
    } catch (e) {
      print('사용자 코스 불러오기 오류: $e');
      rethrow;
    }
  }
}

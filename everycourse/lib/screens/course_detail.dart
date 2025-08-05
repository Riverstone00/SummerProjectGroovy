import 'package:flutter/material.dart';
import 'package:everycourse/services/course_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseDetail extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetail({super.key, required this.course});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  final CourseService _courseService = CourseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isBookmarked = false; // 북마크 상태
  bool _isLiked = false;      // 좋아요 상태
  int _likeCount = 0;         // 좋아요 수
  bool _isLoading = true;     // 로딩 상태

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  // 초기 상태 설정: 북마크/좋아요 여부 확인 및 좋아요 수 로드
  Future<void> _initializeState() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
      if (courseId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 북마크와 좋아요 문서 조회
      final bookmarkDoc = await _firestore.collection('users').doc(user.uid).collection('bookmarks').doc(courseId).get();
      final likeDoc = await _firestore.collection('users').doc(user.uid).collection('likes').doc(courseId).get();
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      final likesFromDb = courseDoc.data()?['likes'] ?? 0;

      setState(() {
        _isBookmarked = bookmarkDoc.exists;
        _isLiked = likeDoc.exists;
        _likeCount = likesFromDb;
        _isLoading = false;
      });
    } catch (e) {
      print('초기화 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  // 좋아요 토글 기능
  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
    final likeRef = _firestore.collection('users').doc(user.uid).collection('likes').doc(courseId);
    final courseRef = _firestore.collection('courses').doc(courseId);

    try {
      if (_isLiked) {
        await likeRef.delete();
        await courseRef.update({'likes': FieldValue.increment(-1)});
        setState(() {
          _isLiked = false;
          _likeCount = (_likeCount - 1).clamp(0, double.infinity).toInt();
        });
      } else {
        await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
        await courseRef.update({'likes': FieldValue.increment(1)});
        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      print('좋아요 토글 오류: $e');
    }
  }

  // 북마크 토글 기능
  Future<void> _toggleBookmark() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요한 기능입니다.')),
      );
      return;
    }

    final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
    if (courseId.isEmpty) {
      print('경고: 북마크 토글 시 코스 ID를 찾을 수 없습니다: ${widget.course}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코스 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    try {
      final bookmarkRef = _firestore.collection('users').doc(user.uid).collection('bookmarks').doc(courseId);

      if (_isBookmarked) {
        await bookmarkRef.delete();
      } else {
        await bookmarkRef.set({
          'courseId': courseId,
          'timestamp': FieldValue.serverTimestamp(),
          'courseData': widget.course,
        });
      }

      setState(() {
        _isBookmarked = !_isBookmarked;
      });

      // 상태에 따라 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? '북마크에 추가되었습니다.' : '북마크에서 제거되었습니다.'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('북마크 토글 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('북마크 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatInfo = _courseService.formatPriceAndTime(widget.course);
    final formattedPrice = formatInfo['formattedPrice'] ?? '가격 정보 없음';
    final formattedTime = formatInfo['formattedTime'] ?? '시간 정보 없음';

    final List<String> hashtags = [];
    if (widget.course['hashtags'] is List) {
      hashtags.addAll((widget.course['hashtags'] as List).map((tag) => '#$tag'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        iconTheme: const IconThemeData(size: 30), // 아이콘 크기 증가
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? Colors.amber : Colors.grey),
            onPressed: _isLoading ? null : _toggleBookmark,
          ),
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? const Color(0xFFFF597B) : Colors.grey),
            onPressed: _isLoading ? null : _toggleLike,
          ),
        ],
      ),

      // 하단 버튼 영역
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFCCCCCC), width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Row(
          children: [
            // 찜 버튼
            GestureDetector(
              onTap: _isLoading ? null : _toggleLike,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? const Color(0xFFFF597B) : Colors.grey, size: 30),
                    const SizedBox(height: 4),
                    Text('찜 $_likeCount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            // 저장 버튼
            Expanded(
              child: ElevatedButton(
                onPressed: _toggleBookmark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF597B),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('저장하기', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),

      // 본문
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 대표 이미지
                  Image.network(
                    widget.course['image'] ?? 'https://via.placeholder.com/300',
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/course1.png', width: double.infinity, height: 260, fit: BoxFit.cover),
                  ),

                  // 제목 + 별점 + 리뷰
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.course['title'] ?? '제목 없음', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              final r = (widget.course['rating'] ?? 0) / 2.0;
                              return Icon(
                                i < r ? Icons.star : (i < r + 0.5 ? Icons.star_half : Icons.star_border),
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text('${widget.course['reviewCount'] ?? 0} (${(widget.course['rating'] ?? 0).toStringAsFixed(1)}/10)',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {},
                              child: const Text('별점주기', style: TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 가격 & 시간 정보
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Text("\u{1F4B0}"),
                        Text(" $formattedPrice  ", style: const TextStyle(color: Colors.grey)),
                        const Text("\u{23F1}"),
                        Text(" $formattedTime", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  // 설명
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Text(widget.course['description'] ?? '설명이 없습니다.', style: const TextStyle(fontSize: 15)),
                  ),

                  // 해시태그
                  if (hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        children: hashtags.map((tag) => Text(tag, style: const TextStyle(color: Colors.grey, fontSize: 13))).toList(),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 장소 리스트
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (widget.course['places'] is List)
                          ...List<Widget>.from(
                            (widget.course['places'] as List).map((place) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _buildPlaceButton(place.toString()),
                                )),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // 장소 버튼 위젯
  Widget _buildPlaceButton(String name) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.place_outlined),
        label: Text(name, style: const TextStyle(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF49CA2),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {},
      ),
    );
  }
}

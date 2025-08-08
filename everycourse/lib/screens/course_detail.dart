// 필요한 패키지 임포트
import 'package:flutter/material.dart';
import 'package:everycourse/services/course_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// CourseDetail 화면 - 선택한 데이트 코스의 상세 정보를 보여주는 StatefulWidget
class CourseDetail extends StatefulWidget {
  final Map<String, dynamic> course; // 파이어스토어에서 받아온 코스 정보

  const CourseDetail({super.key, required this.course});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  // 서비스 및 인증, DB 인스턴스
  final CourseService _courseService = CourseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 상호작용 상태 변수들
  bool _isBookmarked = false;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLoading = true;
  bool _hasRated = false;
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();
    // 전달받은 코스 데이터 로깅
    print('CourseDetail: 전달받은 코스 데이터: ${widget.course}');
    print('CourseDetail: imageUrl = ${widget.course['imageUrl']}');
    print('CourseDetail: image = ${widget.course['image']}');
    print('CourseDetail: description = ${widget.course['description']}');
    print('CourseDetail: title = ${widget.course['title']}');
    _initializeState(); // 초기 상태 불러오기 (좋아요/북마크/별점 등)
  }

  /// 사용자 별 좋아요/북마크/별점 여부를 파이어스토어에서 불러옴
  Future<void> _initializeState() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) return setState(() => _isLoading = false);

      final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
      if (courseId.isEmpty) return setState(() => _isLoading = false);

      // Firestore에서 유저의 좋아요/북마크/별점 문서 조회
      final bookmarkDoc = await _firestore.collection('users').doc(user.uid).collection('bookmarks').doc(courseId).get();
      final likeDoc = await _firestore.collection('users').doc(user.uid).collection('likes').doc(courseId).get();
      final ratingDoc = await _firestore.collection('users').doc(user.uid).collection('ratings').doc(courseId).get();
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();

      final likesFromDb = courseDoc.data()?['likes'] ?? 0;
      final userRating = ratingDoc.data()?['rating']?.toDouble();

      setState(() {
        _isBookmarked = bookmarkDoc.exists;
        _isLiked = likeDoc.exists;
        _likeCount = likesFromDb;
        _hasRated = ratingDoc.exists;
        _userRating = userRating ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      print('초기화 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 좋아요 토글 처리
  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
    final likeRef = _firestore.collection('users').doc(user.uid).collection('likes').doc(courseId);
    final courseRef = _firestore.collection('courses').doc(courseId);

    try {
      if (_isLiked) {
        await likeRef.delete(); // 좋아요 제거
        await courseRef.update({'likes': FieldValue.increment(-1)});
        setState(() {
          _isLiked = false;
          _likeCount = (_likeCount - 1).clamp(0, double.infinity).toInt();
        });
      } else {
        await likeRef.set({'timestamp': FieldValue.serverTimestamp()}); // 좋아요 추가
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

  /// 북마크 토글 처리
  Future<void> _toggleBookmark() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요한 기능입니다.')));
      return;
    }

    final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
    if (courseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('코스 정보를 찾을 수 없습니다.')));
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
      setState(() => _isBookmarked = !_isBookmarked);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isBookmarked ? '북마크에 추가되었습니다.' : '북마크에서 제거되었습니다.'),
        duration: const Duration(seconds: 1),
      ));
    } catch (e) {
      print('북마크 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('북마크 처리 중 오류가 발생했습니다.')));
    }
  }

  /// 별점 다이얼로그 표시
  Future<void> _showRatingDialog() async {
    double tempRating = _userRating;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('별점 주기'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('이 코스에 별점을 매겨주세요'),
                  const SizedBox(height: 20),
                  // 별 아이콘 선택 UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < tempRating / 2 ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                        onPressed: () => setState(() => tempRating = (index + 1) * 2.0),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text('${tempRating.toStringAsFixed(1)}/10', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),
          actions: [
            TextButton(child: const Text('취소'), onPressed: () => Navigator.of(context).pop()),
            TextButton(child: const Text('확인'), onPressed: () {
              Navigator.of(context).pop();
              _submitRating(tempRating); // 별점 저장 로직 호출
            }),
          ],
        );
      },
    );
  }

  /// 별점 저장 및 평균 별점 계산
  Future<void> _submitRating(double rating) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String courseId = widget.course['id'] ?? widget.course['courseId'] ?? '';
    if (courseId.isEmpty) return;

    try {
      // 유저의 별점 저장
      final userRatingRef = _firestore.collection('users').doc(user.uid).collection('ratings').doc(courseId);
      await userRatingRef.set({
        'courseId': courseId,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 전체 평균 별점 및 리뷰 수 업데이트 (트랜잭션으로 처리)
      await _firestore.runTransaction((transaction) async {
        final courseDoc = await transaction.get(_firestore.collection('courses').doc(courseId));
        if (!courseDoc.exists) return;

        final currentRating = courseDoc.data()?['rating'] as num? ?? 0;
        final currentReviewCount = courseDoc.data()?['reviewCount'] as num? ?? 0;

        double newRating;
        int newReviewCount;

        if (_hasRated) {
          // 기존에 평가한 경우 → 별점 수정
          final totalRating = currentRating * currentReviewCount;
          final updatedTotalRating = totalRating - _userRating + rating;
          newRating = currentReviewCount > 0 ? updatedTotalRating / currentReviewCount : 0;
          newReviewCount = currentReviewCount.toInt();
        } else {
          // 첫 평가인 경우 → 리뷰 수 증가
          final totalRating = currentRating * currentReviewCount;
          newReviewCount = currentReviewCount.toInt() + 1;
          newRating = newReviewCount > 0 ? (totalRating + rating) / newReviewCount : 0;
        }

        // 트랜잭션으로 DB 업데이트
        transaction.update(_firestore.collection('courses').doc(courseId), {
          'rating': newRating,
          'reviewCount': newReviewCount,
        });
      });

      // UI 업데이트
      setState(() {
        _userRating = rating;
        _hasRated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점이 등록되었습니다.'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      print('별점 등록 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점 등록 중 오류가 발생했습니다.')),
      );
    }
  }


  // 장소 버튼
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

  // UI 화면 구성
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
        iconTheme: const IconThemeData(size: 30),
        actions: [
          // 북마크, 좋아요 버튼
          IconButton(icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? Colors.amber : Colors.grey), onPressed: _isLoading ? null : _toggleBookmark),
          IconButton(icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? const Color(0xFFFF597B) : Colors.grey), onPressed: _isLoading ? null : _toggleLike),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFCCCCCC), width: 1))),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Row(
          children: [
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 대표 이미지
                  Builder(
                    builder: (context) {
                      String? imageUrl = widget.course['imageUrl'] ?? widget.course['image'];
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 260,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // courseId 기반으로 일관된 이미지 선택
                            String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
                            int imageIndex = courseId.isEmpty 
                                ? 1 // 기본값
                                : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                            if (imageIndex < 0) imageIndex = -imageIndex; // 음수 방지
                            if (imageIndex == 0) imageIndex = 1; // 최소값 1로 보정
                            if (imageIndex > 4) imageIndex = ((imageIndex - 1) % 4) + 1; // 1-4 범위로 제한
                            
                            return Image.asset(
                              'assets/images/course$imageIndex.png', 
                              width: double.infinity, 
                              height: 260, 
                              fit: BoxFit.cover
                            );
                          },
                        );
                      } else {
                        // imageUrl이 없는 경우도 courseId 기반으로 이미지 선택
                        String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
                        int imageIndex = courseId.isEmpty 
                            ? 1 // 기본값
                            : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                        if (imageIndex < 0) imageIndex = -imageIndex; // 음수 방지
                        if (imageIndex == 0) imageIndex = 1; // 최소값 1로 보정
                        if (imageIndex > 4) imageIndex = ((imageIndex - 1) % 4) + 1; // 1-4 범위로 제한
                        
                        return Image.asset(
                          'assets/images/course$imageIndex.png', 
                          width: double.infinity, 
                          height: 260, 
                          fit: BoxFit.cover
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.course['title'] ?? '제목 없음', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        // 별점 표시 + 별점주기
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              final r = (widget.course['rating'] ?? 0) / 2.0;
                              return Icon(i < r ? Icons.star : (i < r + 0.5 ? Icons.star_half : Icons.star_border), color: Colors.amber, size: 20);
                            }),
                            const SizedBox(width: 6),
                            Text('${widget.course['reviewCount'] ?? 0} (${(widget.course['rating'] ?? 0).toStringAsFixed(1)}/10)', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _showRatingDialog,
                              child: const Text('별점주기', style: TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                        // 내가 준 별점
                        if (_hasRated)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Text('내가 준 별점: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('${_userRating.toStringAsFixed(1)}/10', style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 가격/시간/설명
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(children: [const Text('💰'), Text(" $formattedPrice  ", style: const TextStyle(color: Colors.grey)), const Text('⏱'), Text(" $formattedTime", style: const TextStyle(color: Colors.grey))]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Text(widget.course['content'] ?? widget.course['description'] ?? '설명이 없습니다.', style: const TextStyle(fontSize: 15)),
                  ),
                  // 해시태그
                  if (hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Wrap(spacing: 8, children: hashtags.map((tag) => Text(tag, style: const TextStyle(color: Colors.grey, fontSize: 13))).toList()),
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
}

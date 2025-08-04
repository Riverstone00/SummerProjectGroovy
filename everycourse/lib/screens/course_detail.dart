import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:everycourse/services/course_service.dart';

class CourseDetail extends StatefulWidget {
  final String courseId; // Firestore 문서 ID

  const CourseDetail({super.key, required this.courseId});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  bool isBookmarked = false;
  bool isLiked = false;
  double userRating = 0.0;
  double avgRating = 0.0;
  int totalReviews = 0;
  Course? course;
  CourseImage? courseImage;
  List<Hashtag> hashtags = [];
  bool isLoading = true;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadCourseData();
  }

  Future<void> loadCourseData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).get();
      if (doc.exists) {
        final courseMap = doc.data()!;
        course = Course.fromMap(courseMap, doc.id);

        final imageDoc = await FirebaseFirestore.instance
            .collection('course_images')
            .where('postID', isEqualTo: widget.courseId)
            .limit(1)
            .get();
        if (imageDoc.docs.isNotEmpty) {
          courseImage = CourseImage.fromMap(imageDoc.docs.first.data());
        }

        final tagSnapshot = await FirebaseFirestore.instance
            .collection('hashtags')
            .where('postID', isEqualTo: widget.courseId)
            .get();
        hashtags = tagSnapshot.docs.map((doc) => Hashtag.fromMap(doc.data())).toList();

        final likeDoc = await FirebaseFirestore.instance
            .collection('likes')
            .doc('${user!.uid}_${widget.courseId}_like')
            .get();
        isLiked = likeDoc.exists;

        final bookmarkDoc = await FirebaseFirestore.instance
            .collection('bookmarks')
            .doc('${user!.uid}_${widget.courseId}_bookmark')
            .get();
        isBookmarked = bookmarkDoc.exists;

        final reviewSnapshot = await FirebaseFirestore.instance
            .collection('reviews')
            .where('postID', isEqualTo: widget.courseId)
            .get();

        if (reviewSnapshot.docs.isNotEmpty) {
          final ratings = reviewSnapshot.docs.map((doc) => doc['rating'] as int).toList();
          totalReviews = ratings.length;
          avgRating = ratings.reduce((a, b) => a + b) / totalReviews;
        }

        final userReview = await FirebaseFirestore.instance
            .collection('reviews')
            .doc('${user!.uid}_${widget.courseId}_${course!.userID}_review')
            .get();
        if (userReview.exists) {
          userRating = userReview['rating'].toDouble();
        }
      }
    } catch (e) {
      print("Error loading course: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _toggleLike() async {
    final likeRef = FirebaseFirestore.instance.collection('likes').doc('${user!.uid}_${widget.courseId}_like');
    if (isLiked) {
      await likeRef.delete();
    } else {
      await likeRef.set({
        'userID': user!.uid,
        'postID': widget.courseId,
        'key': 'like',
      });
    }
    setState(() => isLiked = !isLiked);
  }

  Future<void> _toggleBookmark() async {
    final bookmarkRef = FirebaseFirestore.instance.collection('bookmarks').doc('${user!.uid}_${widget.courseId}_bookmark');
    if (isBookmarked) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'userID': user!.uid,
        'postID': widget.courseId,
        'key': 'bookmark',
      });
    }
    setState(() => isBookmarked = !isBookmarked);
  }

  void _showRatingDialog() {
    double tempRating = userRating > 0 ? userRating : 5.0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('별점 주기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이 데이트 코스에 몇 점을 주시겠어요?'),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: tempRating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                tempRating = rating;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              final reviewRef = FirebaseFirestore.instance.collection('reviews').doc('${user!.uid}_${widget.courseId}_${course!.userID}_review');
              await reviewRef.set({
                'userID': user!.uid,
                'postID': widget.courseId,
                'userID2': course!.userID,
                'key': 'review',
                'rating': tempRating.round(),
              });
              Navigator.pop(context);
              loadCourseData();
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || course == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? Colors.amber : Colors.grey),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Color(0xFFFF597B) : Colors.grey),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              courseImage?.imageURL ?? 'https://via.placeholder.com/300x200',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(course!.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.red, size: 25),
                  const SizedBox(width: 4),
                  Text('$totalReviews (${avgRating.toStringAsFixed(1)}/5)', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showRatingDialog,
                    child: const Text('별점주기', style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text("💰", style: TextStyle(fontSize: 15)),
                  Text(" ${course!.cost}원 ", style: const TextStyle(color: Colors.grey, fontSize: 15)),
                  const Text("⏱️", style: TextStyle(fontSize: 15)),
                  Text(" ${course!.timeEstimated.inMinutes}분", style: const TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
            if (hashtags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: hashtags.map((tag) => Text('#${tag.normalizedTagName}', style: const TextStyle(color: Colors.grey))).toList(),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: course!.placeOrder.map((place) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildPlaceButton(place.name),
                )).toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceButton(String name) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.place_outlined),
        label: Text(name, style: const TextStyle(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8E9E),
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



/*import 'package:flutter/material.dart';
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
  
  bool _isBookmarked = false;
  double _userRating = 0; // 사용자가 현재 주고 있는 별점
  bool _hasRated = false; // 사용자가 이미 별점을 줬는지 여부
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkUserInteractions();
  }
  
  // 사용자의 별점 및 북마크 상태 확인
  Future<void> _checkUserInteractions() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      // courseId 필드 확인 (course_list.dart와 explore_screen.dart에서는 courseId를 사용함)
      final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
      if (courseId.isEmpty) {
        print('경고: 코스 ID를 찾을 수 없습니다: ${widget.course}');
        setState(() => _isLoading = false);
        return;
      }
      
      // 북마크 상태 확인
      final bookmarkDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(courseId)
          .get();
      
      // 별점 상태 확인
      final ratingDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratings')
          .doc(courseId)
          .get();
      
      setState(() {
        _isBookmarked = bookmarkDoc.exists;
        if (ratingDoc.exists && ratingDoc.data() != null) {
          _userRating = (ratingDoc.data()!['rating'] as num).toDouble();
          _hasRated = true;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('사용자 상호작용 확인 오류: $e');
      setState(() => _isLoading = false);
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
    
    // courseId 필드 확인 (course_list.dart와 explore_screen.dart에서는 courseId를 사용함)
    final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
    if (courseId.isEmpty) {
      print('경고: 북마크 토글 시 코스 ID를 찾을 수 없습니다: ${widget.course}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코스 정보를 찾을 수 없습니다.')),
      );
      return;
    }
    
    try {
      final bookmarkRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(courseId);
      
      if (_isBookmarked) {
        // 북마크 제거
        await bookmarkRef.delete();
      } else {
        // 북마크 추가
        await bookmarkRef.set({
          'courseId': courseId,
          'timestamp': FieldValue.serverTimestamp(),
          'courseData': widget.course,
        });
      }
      
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      
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
  
  // 별점 제출 기능
  Future<void> _submitRating(double rating) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요한 기능입니다.')),
      );
      return;
    }
    
    // courseId 필드 확인 (course_list.dart와 explore_screen.dart에서는 courseId를 사용함)
    final String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
    if (courseId.isEmpty) {
      print('경고: 별점 제출 시 코스 ID를 찾을 수 없습니다: ${widget.course}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코스 정보를 찾을 수 없습니다.')),
      );
      return;
    }
    
    try {
      // 사용자 별점 저장
      final userRatingRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratings')
          .doc(courseId);
      
      await userRatingRef.set({
        'courseId': courseId,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // 코스 평점 업데이트를 위한 트랜잭션
      await _firestore.runTransaction((transaction) async {
        // 코스 문서 가져오기
        final courseDoc = await transaction.get(_firestore.collection('courses').doc(courseId));
        
        if (!courseDoc.exists) {
          return;
        }
        
        // 현재 평점 정보
        final currentRating = courseDoc.data()?['rating'] as num? ?? 0;
        final currentReviewCount = courseDoc.data()?['reviewCount'] as num? ?? 0;
        
        double newRating;
        int newReviewCount;
        
        if (_hasRated) {
          // 기존 별점 업데이트 (평균 재계산)
          final totalRating = currentRating * currentReviewCount;
          final updatedTotalRating = totalRating - _userRating + rating;
          newRating = currentReviewCount > 0 ? updatedTotalRating / currentReviewCount : 0;
          newReviewCount = currentReviewCount.toInt();
        } else {
          // 새로운 별점 추가
          final totalRating = currentRating * currentReviewCount;
          newReviewCount = currentReviewCount.toInt() + 1;
          newRating = newReviewCount > 0 ? (totalRating + rating) / newReviewCount : 0;
        }
        
        // 코스 문서 업데이트
        transaction.update(_firestore.collection('courses').doc(courseId), {
          'rating': newRating,
          'reviewCount': newReviewCount,
        });
      });
      
      setState(() {
        _userRating = rating;
        _hasRated = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('별점이 등록되었습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('별점 등록 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점 등록 중 오류가 발생했습니다.')),
      );
    }
  }
  
  // 별점 선택 다이얼로그
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < tempRating / 2 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            tempRating = (index + 1) * 2.0; // 1-5 별점을 2-10으로 변환
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text('${tempRating.toStringAsFixed(1)}/10', 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitRating(tempRating);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 가격과 시간 정보 포맷
    final formatInfo = _courseService.formatPriceAndTime(widget.course);
    final formattedPrice = formatInfo['formattedPrice'] ?? '가격 정보 없음';
    final formattedTime = formatInfo['formattedTime'] ?? '시간 정보 없음';
    
    // 해시태그 처리
    final List<String> hashtags = [];
    if (widget.course['hashtags'] != null) {
      if (widget.course['hashtags'] is List) {
        hashtags.addAll((widget.course['hashtags'] as List).map((tag) => '#$tag').toList());
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F5),
      appBar: AppBar(
        title: const Text(''), // 제목 제거
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // 북마크 버튼
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? Colors.red : Colors.black,
            ),
            onPressed: _isLoading ? null : _toggleBookmark,
          ),
          // 별점 버튼
          IconButton(
            icon: const Icon(Icons.star_rate),
            color: _hasRated ? Colors.amber : Colors.black,
            onPressed: _isLoading ? null : _showRatingDialog,
          ),
        ],
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
                      String? imageUrl = widget.course['imageUrl'];
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 260,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('상세 이미지 로드 오류($imageUrl): $error');
                            // courseId 기반으로 일관된 이미지 선택 (목록 화면과 동일한 방식)
                            String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
                            int imageIndex = courseId.isEmpty 
                                ? 1 
                                : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                            return Image.asset(
                              'assets/images/course$imageIndex.png',
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      } else {
                        // imageUrl이 없는 경우도 courseId 기반으로 이미지 선택
                        String courseId = widget.course['courseId'] ?? widget.course['id'] ?? '';
                        int imageIndex = courseId.isEmpty 
                            ? 1 
                            : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                        return Image.asset(
                          'assets/images/course$imageIndex.png',
                          width: double.infinity,
                          height: 260,
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),

                  // 제목
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      widget.course['title'] ?? '제목 없음',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // 별점
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildRatingStars(widget.course['rating']),
                        const SizedBox(width: 6),
                        Text(
                          widget.course['reviewCount'] != null 
                              ? '${widget.course['reviewCount']} (${(widget.course['rating'] as num?)?.toStringAsFixed(1) ?? '0.0'}/10)' 
                              : '0 (0.0/10)',
                          style: TextStyle(color: Colors.grey[700], fontSize: 14)
                        ),
                      ],
                    ),
                  ),

                  // 내 별점 표시 (별점을 준 경우에만)
                  if (_hasRated)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          const Text("내가 준 별점: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text("${_userRating.toStringAsFixed(1)}/10", 
                              style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  // 가격 및 시간
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Text("💰", style: TextStyle(fontSize: 14)),
                        Text(" $formattedPrice  ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const Text("⏱️", style: TextStyle(fontSize: 14)),
                        Text(" $formattedTime", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),

                  // 설명
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Text(
                      widget.course['description'] ?? '설명이 없습니다.',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),

                  // 해시태그
                  if (hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        children: hashtags
                            .map((tag) => Text(tag, style: const TextStyle(color: Colors.grey, fontSize: 13)))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 장소 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (widget.course['location'] != null)
                          _buildPlaceButton(widget.course['location']),
                        if (widget.course['place'] != null && widget.course['place'] != widget.course['location'])
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildPlaceButton(widget.course['place']),
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
  
  // 별점 표시 위젯
  Widget _buildRatingStars(dynamic rating) {
    double ratingValue = 0;
    if (rating != null) {
      if (rating is num) {
        ratingValue = rating.toDouble();
      }
    }
    
    // 10점 만점을 5점 척도로 변환
    ratingValue = ratingValue / 2;
    
    List<Widget> stars = [];
    
    // 전체 별 아이콘 생성
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      Color color = Colors.amber;
      
      if (i <= ratingValue) {
        iconData = Icons.star; // 꽉 찬 별
      } else if (i > ratingValue && i <= ratingValue + 0.5) {
        iconData = Icons.star_half; // 반 별
      } else {
        iconData = Icons.star_border; // 빈 별
      }
      
      stars.add(Icon(iconData, color: color, size: 20));
    }
    
    return Row(children: stars);
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
}*/

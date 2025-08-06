import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everycourse/screens/course_detail.dart';

class BookmarkedCoursesPage extends StatefulWidget {
  const BookmarkedCoursesPage({super.key});

  @override
  State<BookmarkedCoursesPage> createState() => _BookmarkedCoursesPageState();
}

class _BookmarkedCoursesPageState extends State<BookmarkedCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> _bookmarkedCourses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedCourses();
  }

  Future<void> _loadBookmarkedCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 현재 로그인한 사용자 확인
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = '로그인이 필요한 기능입니다.';
        });
        return;
      }

      // 사용자의 북마크 컬렉션 가져오기
      final bookmarkSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .orderBy('timestamp', descending: true)
          .get();

      final bookmarkedCourses = <Map<String, dynamic>>[];

      // 북마크 데이터 처리
      for (var doc in bookmarkSnapshot.docs) {
        final data = doc.data();
        
        // courseData 필드에 저장된 코스 정보 사용
        if (data.containsKey('courseData') && data['courseData'] != null) {
          final courseData = data['courseData'] as Map<String, dynamic>;
          
          // 최신 코스 정보 가져오기 (rating 등의 실시간 데이터를 위해)
          try {
            final String courseId = courseData['courseId'] ?? courseData['id'] ?? doc.id;
            final courseDoc = await _firestore.collection('courses').doc(courseId).get();
            
            if (courseDoc.exists) {
              final latestData = courseDoc.data() as Map<String, dynamic>;
              
              // 중요 필드 업데이트 (rating, reviewCount 등)
              courseData['rating'] = latestData['rating'];
              courseData['reviewCount'] = latestData['reviewCount'];
              courseData['viewcount'] = latestData['viewcount'];
            }
          } catch (e) {
            print('북마크 코스 최신 정보 가져오기 오류: $e');
          }
          
          // 북마크 정보 추가
          courseData['bookmarkId'] = doc.id;
          courseData['bookmarkTimestamp'] = data['timestamp'];
          
          bookmarkedCourses.add(courseData);
        }
        // 또는 courseId 필드가 있으면 코스 정보를 직접 가져오기
        else if (data.containsKey('courseId') && data['courseId'] is String) {
          try {
            final courseDoc = await _firestore
                .collection('courses')
                .doc(data['courseId'])
                .get();
                
            if (courseDoc.exists) {
              final courseData = courseDoc.data() as Map<String, dynamic>;
              
              // 북마크 및 코스 ID 정보 추가
              courseData['courseId'] = courseDoc.id;
              courseData['bookmarkId'] = doc.id;
              courseData['bookmarkTimestamp'] = data['timestamp'];
              
              bookmarkedCourses.add(courseData);
            }
          } catch (e) {
            print('코스 정보 가져오기 오류: $e');
          }
        }
      }

      setState(() {
        _bookmarkedCourses = bookmarkedCourses;
        _isLoading = false;
        
        if (bookmarkedCourses.isEmpty) {
          _errorMessage = '북마크한 코스가 없습니다.';
        }
      });
    } catch (e) {
      print('북마크 코스 로드 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '북마크 목록을 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  Future<void> _removeBookmark(String bookmarkId, int index) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Firestore에서 북마크 삭제
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(bookmarkId)
          .delete();

      // 로컬 목록에서 제거
      setState(() {
        _bookmarkedCourses.removeAt(index);
        if (_bookmarkedCourses.isEmpty) {
          _errorMessage = '북마크한 코스가 없습니다.';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('북마크가 삭제되었습니다.')),
        );
      }
    } catch (e) {
      print('북마크 삭제 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('북마크 삭제 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '북마크한 코스',
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (_errorMessage == '북마크한 코스가 없습니다.') ...[
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('코스 탐색하기'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookmarkedCourses,
                  color: Colors.pink,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookmarkedCourses.length,
                    itemBuilder: (context, index) {
                      final course = _bookmarkedCourses[index];
                      final bookmarkId = course['bookmarkId'];
                      
                      return Dismissible(
                        key: Key(bookmarkId),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('북마크 삭제'),
                                content: const Text('이 코스를 북마크에서 삭제하시겠습니까?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          _removeBookmark(bookmarkId, index);
                        },
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              // 코스 상세 페이지로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetail(course: course),
                                ),
                              ).then((_) {
                                // 상세 페이지에서 돌아오면 북마크 상태가 변경되었을 수 있으므로 새로고침
                                _loadBookmarkedCourses();
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 이미지
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      String? imageUrl = course['imageUrl'];
                                      if (imageUrl != null && imageUrl.isNotEmpty) {
                                        return Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // courseId 기반으로 일관된 이미지 선택 (목록 화면과 동일한 방식)
                                            String courseId = course['courseId'] ?? course['id'] ?? course['bookmarkId'] ?? '';
                                            int imageIndex = courseId.isEmpty 
                                                ? 1 
                                                : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                                            return Image.asset(
                                              'assets/images/course$imageIndex.png',
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        );
                                      } else {
                                        // imageUrl이 없는 경우도 courseId 기반으로 이미지 선택
                                        String courseId = course['courseId'] ?? course['id'] ?? course['bookmarkId'] ?? '';
                                        int imageIndex = courseId.isEmpty 
                                            ? 1 
                                            : (courseId.hashCode % 4) + 1; // 1-4 사이의 값
                                        return Image.asset(
                                          'assets/images/course$imageIndex.png',
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 코스 제목
                                      Text(
                                        course['title'] ?? '제목 없음',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // 장소 정보
                                      if (course['location'] != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.place, size: 16, color: Colors.pinkAccent),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                course['location'],
                                                style: const TextStyle(color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // 평점 및 가격 정보
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${(course['rating'] as num?)?.toStringAsFixed(1) ?? '0.0'}/10',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          if (course['price'] != null && course['price'] is num)
                                            Text(
                                              '₩${_formatPrice(course['price'])}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
  
  String _formatPrice(num price) {
    if (price == 0) return '무료';
    
    if (price >= 10000) {
      final tenThousand = price ~/ 10000;
      final remainder = price % 10000;
      
      if (remainder == 0) {
        return '${tenThousand}만원';
      } else {
        return '${tenThousand}만 ${remainder}원';
      }
    } else {
      return '${price}원';
    }
  }
}

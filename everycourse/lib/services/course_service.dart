import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 새 코스를 Firestore에 추가하는 함수
  Future<String> addCourse(Map<String, dynamic> courseData, String userId) async {
    try {
      // 코스 데이터에 userId와 createdAt 필드 추가
      courseData['userId'] = userId;
      courseData['createdAt'] = FieldValue.serverTimestamp();
      
      // viewcount 필드 초기화 (기본값 0)
      if (!courseData.containsKey('viewcount')) {
        courseData['viewcount'] = 0;
      }
      
      // hashtags 필드가 없으면 빈 배열로 초기화
      if (!courseData.containsKey('hashtags')) {
        courseData['hashtags'] = [];
        
        // location이 있으면 해시태그로 자동 추가
        if (courseData.containsKey('location') && courseData['location'] != null) {
          String location = courseData['location'];
          courseData['hashtags'].add(location);
        }
      }
      
      // 'courses' 컬렉션에 데이터 추가하고 문서 ID 반환
      final docRef = await _firestore.collection('courses').add(courseData);
      return docRef.id;
    } catch (e) {
      print('코스 추가 오류: $e');
      rethrow;
    }
  }

  // 모든 코스 가져오기
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['courseId'] = doc.id; // 문서 ID를 courseId로 추가
        return data;
      }).toList();
    } catch (e) {
      print('코스 가져오기 오류: $e');
      return [];
    }
  }
  
  // 코스 조회수 증가시키기
  Future<bool> incrementCourseViewCount(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'viewcount': FieldValue.increment(1)
      });
      return true;
    } catch (e) {
      print('코스 조회수 증가 오류: $e');
      return false;
    }
  }

  // 특정 사용자가 추가한 코스 목록 가져오기
  Future<List<Map<String, dynamic>>> getUserCourses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['courseId'] = doc.id; // 문서 ID를 courseId로 추가
        return data;
      }).toList();
    } catch (e) {
      print('사용자 코스 가져오기 오류: $e');
      return [];
    }
  }

  // 더미 코스 데이터를 Firestore에 추가하는 함수
  Future<List<String>> addDummyCoursesToFirestore(
    List<Map<String, dynamic>> courses, String userId) async {
    try {
      List<String> addedCourseIds = [];
      
      // 각 코스를 개별적으로 추가
      for (var course in courses) {
        // price와 time 필드 제거 (필요 없음)
        if (course.containsKey('price')) {
          course.remove('price');
        }
        if (course.containsKey('time')) {
          course.remove('time');
        }
        
        // 각 코스에 해시태그 추가
        if (!course.containsKey('hashtags')) {
          List<String> hashtags = ["동국대학교"];  // 모든 더미 데이터에 "동국대학교" 해시태그 추가
          
          // location을 해시태그로 추가 (동국대학교와 중복되지 않는 경우에만)
          if (course.containsKey('location') && course['location'] != null && course['location'] != "동국대학교") {
            hashtags.add(course['location']);
          }
          
          // 제목에서 키워드 추출해서 해시태그로 추가
          if (course.containsKey('title') && course['title'] != null) {
            List<String> keywords = _extractKeywords(course['title']);
            hashtags.addAll(keywords);
          }
          
          // 가격 및 시간 관련 해시태그는 생성하지 않음 - 쿼리에서 조건으로 처리
          
          course['hashtags'] = hashtags;
        }
        
        // places 배열 초기화 (빈 배열로)
        if (!course.containsKey('places')) {
          course['places'] = [];
        }
        
        String docId = await addCourse(course, userId);
        addedCourseIds.add(docId);
      }
      
      print('${courses.length}개의 더미 코스가 성공적으로 추가되었습니다.');
      return addedCourseIds;
    } catch (e) {
      print('더미 코스 추가 오류: $e');
      rethrow;
    }
  }
  
  // 제목에서 키워드 추출 (간단한 구현)
  List<String> _extractKeywords(String title) {
    List<String> result = [];
    
    // 콤마, 공백으로 분리
    List<String> words = title.split(RegExp(r'[,\s]+'));
    
    // 2글자 이상인 단어만 선택
    for (String word in words) {
      if (word.length >= 2) {
        result.add(word);
      }
    }
    
    return result;
  }
  
  // priceAmount 및 timeMinutes에서 표시용 문자열 생성
  Map<String, String> formatPriceAndTime(Map<String, dynamic> course) {
    Map<String, String> result = {};
    
    // 가격 숫자를 표시용 문자열로 변환
    if (course.containsKey('priceAmount')) {
      int price = course['priceAmount'];
      
      // 포맷된 가격 문자열 (예: "30,000원")
      final formatter = NumberFormat('#,###');
      result['formattedPrice'] = '${formatter.format(price)}원';
    }
    
    // 시간(분)을 표시용 문자열로 변환
    if (course.containsKey('timeMinutes')) {
      int minutes = course['timeMinutes'];
      
      // 포맷된 시간 문자열 (예: "2시간 30분")
      int hoursPart = minutes ~/ 60;
      int minutesPart = minutes % 60;
      String formattedTime = "";
      
      if (hoursPart > 0) {
        formattedTime += '$hoursPart시간 ';
      }
      if (minutesPart > 0) {
        formattedTime += '$minutesPart분';
      }
      
      result['formattedTime'] = formattedTime;
    }
    
    return result;
  }
  
  // 단일 해시태그로 코스 검색하기
  Future<List<Map<String, dynamic>>> getCoursesByHashtag(String hashtag) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('hashtags', arrayContains: hashtag)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['courseId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('해시태그 검색 오류: $e');
      return [];
    }
  }
  
  // 인기 해시태그 목록 가져오기 (임시 구현 - 실제로는 별도의 통계 컬렉션을 사용하는 것이 좋음)
  Future<List<Map<String, dynamic>>> getPopularHashtags({int limit = 10}) async {
    try {
      // 모든 코스 가져오기
      final courses = await getAllCourses();
      
      // 해시태그 카운팅
      Map<String, int> tagCounts = {};
      for (var course in courses) {
        if (course.containsKey('hashtags')) {
          List<dynamic> hashtags = course['hashtags'];
          for (var tag in hashtags) {
            if (tagCounts.containsKey(tag)) {
              tagCounts[tag] = tagCounts[tag]! + 1;
            } else {
              tagCounts[tag] = 1;
            }
          }
        }
      }
      
      // 인기순으로 정렬
      var sortedEntries = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // 결과 생성
      List<Map<String, dynamic>> result = [];
      for (var i = 0; i < limit && i < sortedEntries.length; i++) {
        result.add({
          'tag': sortedEntries[i].key,
          'count': sortedEntries[i].value,
        });
      }
      
      return result;
    } catch (e) {
      print('인기 해시태그 가져오기 오류: $e');
      return [];
    }
  }
  
  // 다중 해시태그로 검색 (모든 태그를 포함하는 코스)
  Future<List<Map<String, dynamic>>> getCoursesByMultipleHashtags(List<String> hashtags) async {
    try {
      if (hashtags.isEmpty) {
        return [];
      }
      
      // 첫 번째 해시태그로 검색
      final firstResult = await getCoursesByHashtag(hashtags[0]);
      
      // 나머지 해시태그로 필터링
      return firstResult.where((course) {
        List<dynamic> courseTags = course['hashtags'] ?? [];
        for (var tag in hashtags.skip(1)) {
          if (!courseTags.contains(tag)) {
            return false;
          }
        }
        return true;
      }).toList();
    } catch (e) {
      print('다중 해시태그 검색 오류: $e');
      return [];
    }
  }
  
  // 시간과 가격 조건으로 코스 검색하기
  Future<List<Map<String, dynamic>>> getCoursesByPriceAndTime({
    int? maxPrice,
    int? minPrice,
    int? maxTimeMinutes,
    int? minTimeMinutes,
    List<String>? hashtags,
  }) async {
    try {
      // 기본 쿼리 시작
      Query query = _firestore.collection('courses');
      
      // 해시태그 필터링이 있다면 적용
      if (hashtags != null && hashtags.isNotEmpty) {
        // Firestore는 한 번에 하나의 arrayContains만 사용 가능
        // 첫 번째 해시태그로 필터링
        query = query.where('hashtags', arrayContains: hashtags.first);
      }
      
      // 쿼리 실행
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      // 결과를 문서 형태로 변환
      List<Map<String, dynamic>> courses = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['courseId'] = doc.id;
        return data;
      }).toList();
      
      // 클라이언트 측에서 추가 필터링 수행
      return courses.where((course) {
        // 가격 조건 확인
        if (maxPrice != null && course.containsKey('priceAmount')) {
          int price = course['priceAmount'];
          if (price > maxPrice) return false;
        }
        
        if (minPrice != null && course.containsKey('priceAmount')) {
          int price = course['priceAmount'];
          if (price < minPrice) return false;
        }
        
        // 시간 조건 확인
        if (maxTimeMinutes != null && course.containsKey('timeMinutes')) {
          int minutes = course['timeMinutes'];
          if (minutes > maxTimeMinutes) return false;
        }
        
        if (minTimeMinutes != null && course.containsKey('timeMinutes')) {
          int minutes = course['timeMinutes'];
          if (minutes < minTimeMinutes) return false;
        }
        
        // 나머지 해시태그 확인 (첫 번째 이외의 것들)
        if (hashtags != null && hashtags.length > 1) {
          List<dynamic> courseTags = course['hashtags'] ?? [];
          for (var tag in hashtags.skip(1)) {
            if (!courseTags.contains(tag)) return false;
          }
        }
        
        return true;
      }).toList();
    } catch (e) {
      print('가격 및 시간 조건 검색 오류: $e');
      return [];
    }
  }
  
  // ================ Place(장소) 관련 기능 ================
  
  // 장소 데이터를 Firestore에 추가하는 함수
  Future<String> addPlace(Map<String, dynamic> placeData) async {
    try {
      // 필수 필드 확인 (name)
      if (!placeData.containsKey('name') || placeData['name'] == null) {
        throw ArgumentError('장소 이름(name)은 필수 필드입니다.');
      }
      
      // 기본 필드 추가
      placeData['createdAt'] = FieldValue.serverTimestamp();
      
      // 'places' 컬렉션에 데이터 추가하고 문서 ID 반환
      final docRef = await _firestore.collection('places').add(placeData);
      return docRef.id;
    } catch (e) {
      print('장소 추가 오류: $e');
      rethrow;
    }
  }
  
  // 모든 장소 가져오기
  Future<List<Map<String, dynamic>>> getAllPlaces() async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['placeId'] = doc.id; // 문서 ID를 placeId로 추가
        return data;
      }).toList();
    } catch (e) {
      print('장소 가져오기 오류: $e');
      return [];
    }
  }
  
  // 카테고리별 장소 가져오기 함수를 제거하고, 이름으로 장소 검색하는 함수 추가
  Future<List<Map<String, dynamic>>> searchPlacesByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .orderBy('name')
          .startAt([name])
          .endAt([name + '\uf8ff'])
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['placeId'] = doc.id; // 문서 ID를 placeId로 추가
        return data;
      }).toList();
    } catch (e) {
      print('이름으로 장소 검색 오류: $e');
      return [];
    }
  }
  
  // 장소 삭제하기
  Future<bool> deletePlace(String placeId) async {
    try {
      await _firestore.collection('places').doc(placeId).delete();
      return true;
    } catch (e) {
      print('장소 삭제 오류: $e');
      return false;
    }
  }
  
  // 장소 정보 업데이트하기
  Future<bool> updatePlace(String placeId, Map<String, dynamic> newData) async {
    try {
      await _firestore.collection('places').doc(placeId).update(newData);
      return true;
    } catch (e) {
      print('장소 업데이트 오류: $e');
      return false;
    }
  }
  
  // 코스에 장소 추가하기
  Future<bool> addPlaceToCourse(String courseId, String placeId, int order) async {
    try {
      // 코스 문서 가져오기
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      
      if (!courseDoc.exists) {
        print('코스가 존재하지 않습니다: $courseId');
        return false;
      }
      
      // 장소 문서 가져오기
      final placeDoc = await _firestore.collection('places').doc(placeId).get();
      
      if (!placeDoc.exists) {
        print('장소가 존재하지 않습니다: $placeId');
        return false;
      }
      
      // 코스 데이터에서 places 배열 가져오기
      final courseData = courseDoc.data()!;
      List<dynamic> places = courseData['places'] ?? [];
      
      // 장소 참조 데이터 생성
      Map<String, dynamic> placeRef = {
        'placeId': placeId,
        'order': order,
        'addedAt': FieldValue.serverTimestamp(),
      };
      
      // 기존 순서 확인 (동일한 순서가 있으면 뒤로 밀기)
      for (int i = 0; i < places.length; i++) {
        if (places[i]['order'] >= order) {
          places[i]['order'] = places[i]['order'] + 1;
        }
      }
      
      // 새 장소 추가
      places.add(placeRef);
      
      // 순서대로 정렬
      places.sort((a, b) => a['order'].compareTo(b['order']));
      
      // 코스 업데이트
      await _firestore.collection('courses').doc(courseId).update({
        'places': places,
      });
      
      return true;
    } catch (e) {
      print('코스에 장소 추가 오류: $e');
      return false;
    }
  }
  
  // 코스에서 장소 제거하기
  Future<bool> removePlaceFromCourse(String courseId, String placeId) async {
    try {
      // 코스 문서 가져오기
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      
      if (!courseDoc.exists) {
        print('코스가 존재하지 않습니다: $courseId');
        return false;
      }
      
      // 코스 데이터에서 places 배열 가져오기
      final courseData = courseDoc.data()!;
      List<dynamic> places = courseData['places'] ?? [];
      
      // 제거할 장소 찾기
      int removeIndex = -1;
      int removedOrder = -1;
      
      for (int i = 0; i < places.length; i++) {
        if (places[i]['placeId'] == placeId) {
          removeIndex = i;
          removedOrder = places[i]['order'];
          break;
        }
      }
      
      if (removeIndex == -1) {
        print('코스에서 장소를 찾을 수 없습니다: $placeId');
        return false;
      }
      
      // 장소 제거
      places.removeAt(removeIndex);
      
      // 순서 조정
      for (int i = 0; i < places.length; i++) {
        if (places[i]['order'] > removedOrder) {
          places[i]['order'] = places[i]['order'] - 1;
        }
      }
      
      // 코스 업데이트
      await _firestore.collection('courses').doc(courseId).update({
        'places': places,
      });
      
      return true;
    } catch (e) {
      print('코스에서 장소 제거 오류: $e');
      return false;
    }
  }
  
  // 코스 내 장소 순서 변경하기
  Future<bool> reorderPlaceInCourse(String courseId, String placeId, int newOrder) async {
    try {
      // 코스 문서 가져오기
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      
      if (!courseDoc.exists) {
        print('코스가 존재하지 않습니다: $courseId');
        return false;
      }
      
      // 코스 데이터에서 places 배열 가져오기
      final courseData = courseDoc.data()!;
      List<dynamic> places = List.from(courseData['places'] ?? []);
      
      // 변경할 장소 찾기
      int placeIndex = -1;
      int oldOrder = -1;
      
      for (int i = 0; i < places.length; i++) {
        if (places[i]['placeId'] == placeId) {
          placeIndex = i;
          oldOrder = places[i]['order'];
          break;
        }
      }
      
      if (placeIndex == -1) {
        print('코스에서 장소를 찾을 수 없습니다: $placeId');
        return false;
      }
      
      // 순서 변경
      if (oldOrder < newOrder) {
        // 앞에서 뒤로 이동하는 경우
        for (int i = 0; i < places.length; i++) {
          if (places[i]['order'] > oldOrder && places[i]['order'] <= newOrder) {
            places[i]['order'] = places[i]['order'] - 1;
          }
        }
      } else if (oldOrder > newOrder) {
        // 뒤에서 앞으로 이동하는 경우
        for (int i = 0; i < places.length; i++) {
          if (places[i]['order'] >= newOrder && places[i]['order'] < oldOrder) {
            places[i]['order'] = places[i]['order'] + 1;
          }
        }
      }
      
      // 대상 장소 순서 변경
      places[placeIndex]['order'] = newOrder;
      
      // 순서대로 정렬
      places.sort((a, b) => a['order'].compareTo(b['order']));
      
      // 코스 업데이트
      await _firestore.collection('courses').doc(courseId).update({
        'places': places,
      });
      
      return true;
    } catch (e) {
      print('장소 순서 변경 오류: $e');
      return false;
    }
  }
  
  // 더미 장소 데이터를 Firestore에 추가하는 함수
  Future<List<String>> addDummyPlacesToFirestore(
    List<Map<String, dynamic>> places, String userId) async {
    try {
      List<String> addedPlaceIds = [];
      
      // 각 장소를 개별적으로 추가
      for (var place in places) {
        // userId 필드 추가
        place['userId'] = userId;
        
        String docId = await addPlace(place);
        addedPlaceIds.add(docId);
      }
      
      print('${places.length}개의 더미 장소가 성공적으로 추가되었습니다.');
      return addedPlaceIds;
    } catch (e) {
      print('더미 장소 추가 오류: $e');
      rethrow;
    }
  }
  
  // 더미 장소와 코스를 연결하는 함수
  Future<bool> connectDummyPlacesToCourse(
    String courseId, List<String> placeIds) async {
    try {
      // 각 장소를 순서대로 코스에 추가
      for (int i = 0; i < placeIds.length; i++) {
        await addPlaceToCourse(courseId, placeIds[i], i);
      }
      
      print('${placeIds.length}개의 장소가 코스에 성공적으로 연결되었습니다.');
      return true;
    } catch (e) {
      print('장소-코스 연결 오류: $e');
      return false;
    }
  }
  
  // 이미지 URL 유효성 검사 및 처리
  String? validateImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      print('이미지 URL이 null 또는 빈 문자열입니다.');
      return null;
    }
    
    // URL 형식 검사
    Uri? uri = Uri.tryParse(url);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      print('유효하지 않은 이미지 URL 형식: $url');
      return null;
    }
    
    // 상대 경로인 경우 절대 경로로 변환 시도
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      print('상대 경로 URL: $url - 절대 경로로 변환 시도');
      if (url.startsWith('/')) {
        return 'https://firebasestorage.googleapis.com$url';
      } else {
        return 'https://firebasestorage.googleapis.com/$url';
      }
    }
    
    print('유효한 이미지 URL: $url');
    return url;
  }
}

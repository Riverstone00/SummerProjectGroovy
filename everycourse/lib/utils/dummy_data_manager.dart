import 'package:everycourse/services/course_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DummyDataManager {
  final CourseService _courseService = CourseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 더미 데이터 추가 메서드
  Future<void> addAllDummyData() async {
    try {
      // 현재 로그인한 사용자 ID 가져오기
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('로그인된 사용자가 없습니다.');
        return;
      }
      
      // 더미 장소 데이터 생성
      final dummyPlaces = _createDummyPlaces();
      
      // 더미 장소 데이터 추가
      final addedPlaceIds = await _courseService.addDummyPlacesToFirestore(
        dummyPlaces, currentUser.uid);
      
      // 더미 코스 데이터 생성
      final dummyCourses = _createDummyCourses();
      
      // 더미 코스 데이터 추가
      final addedCourseIds = await _courseService.addDummyCoursesToFirestore(
        dummyCourses, currentUser.uid);
      
      // 더미 장소와 코스 연결 (예: 첫 번째 코스에 첫 두 개의 장소 연결)
      if (addedCourseIds.isNotEmpty && addedPlaceIds.length >= 2) {
        await _courseService.connectDummyPlacesToCourse(
          addedCourseIds[0], addedPlaceIds.sublist(0, 2));
      }
      
      print('모든 더미 데이터가 성공적으로 추가되었습니다.');
    } catch (e) {
      print('더미 데이터 추가 오류: $e');
    }
  }
  
  // 더미 장소 데이터 생성
  List<Map<String, dynamic>> _createDummyPlaces() {
    return [
      {
        'name': '동국대학교 중앙도서관',
        'category': '교육',
        'address': '서울특별시 중구 필동로 1길 30',
        'description': '동국대학교의 중앙도서관으로 학생들의 공부 및 연구 활동을 지원합니다.',
        'openHours': '09:00-22:00',
        'rating': 4.5,
        'latitude': 37.558195,
        'longitude': 127.000179,
        'imageUrl': 'https://example.com/images/library.jpg',
      },
      {
        'name': '남산 둘레길',
        'category': '자연',
        'address': '서울특별시 중구 예장동',
        'description': '서울 남산의 둘레를 걸을 수 있는 산책로로, 도심 속 자연을 즐길 수 있습니다.',
        'openHours': '항상 개방',
        'rating': 4.7,
        'latitude': 37.551416,
        'longitude': 126.988254,
        'imageUrl': 'https://example.com/images/namsan.jpg',
      },
      {
        'name': '을지로 카페거리',
        'category': '카페',
        'address': '서울특별시 중구 을지로',
        'description': '독특한 분위기의 카페들이 모여있는 거리로, 젊은이들에게 인기가 많습니다.',
        'openHours': '12:00-22:00',
        'rating': 4.6,
        'latitude': 37.566345,
        'longitude': 126.993210,
        'imageUrl': 'https://example.com/images/cafes.jpg',
      },
      {
        'name': '창덕궁',
        'category': '역사',
        'address': '서울특별시 종로구 율곡로 99',
        'description': '조선시대 5대 궁궐 중 하나로, 유네스코 세계문화유산으로 등재되어 있습니다.',
        'openHours': '09:00-17:00',
        'rating': 4.8,
        'latitude': 37.579617,
        'longitude': 126.991122,
        'imageUrl': 'https://example.com/images/palace.jpg',
      },
      {
        'name': '명동 쇼핑거리',
        'category': '쇼핑',
        'address': '서울특별시 중구 명동',
        'description': '서울의 대표적인 쇼핑 명소로, 화장품, 의류 등 다양한 상점이 있습니다.',
        'openHours': '10:00-22:00',
        'rating': 4.4,
        'latitude': 37.563826,
        'longitude': 126.982652,
        'imageUrl': 'https://example.com/images/shopping.jpg',
      },
    ];
  }
  
  // 추가 더미 코스 데이터 생성 (places 필드 포함)
  List<Map<String, dynamic>> _createDummyCourses() {
    return [
      {
        'title': '동국대 주변 데이트 코스',
        'description': '동국대학교 주변의 아름다운 장소들을 탐방하는 데이트 코스입니다.',
        'location': '서울 중구',
        'priceAmount': 30000,
        'timeMinutes': 180,
        'imageUrl': 'https://example.com/images/dongguk_date.jpg',
        'places': [], // 나중에 장소가 연결됩니다
      },
      {
        'title': '서울 역사 탐방',
        'description': '서울의 역사적인 장소들을 둘러보는 문화 코스입니다.',
        'location': '서울 종로구',
        'priceAmount': 20000,
        'timeMinutes': 240,
        'imageUrl': 'https://example.com/images/history_tour.jpg',
        'places': [], // 나중에 장소가 연결됩니다
      },
      {
        'title': '카페 투어',
        'description': '서울의 유명한 카페들을 방문하는 여유로운 코스입니다.',
        'location': '서울 용산구',
        'priceAmount': 50000,
        'timeMinutes': 180,
        'imageUrl': 'https://example.com/images/cafe_tour.jpg',
        'places': [], // 나중에 장소가 연결됩니다
      },
    ];
  }
}

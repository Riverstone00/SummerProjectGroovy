import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_service.dart';

class RegionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CourseService _courseService = CourseService();

  // 모든 지역 가져오기
  Future<List<Map<String, dynamic>>> getAllRegions() async {
    try {
      final querySnapshot = await _firestore.collection('regions').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final schools = data['schools'] as List<dynamic>? ?? [];
        return {
          'id': doc.id, // Firebase 자동 생성 ID
          'name': data['regionName'] ?? '', // regionName 사용
          'locations': schools.map((school) => school['name'] ?? '').toList(),
        };
      }).toList();
    } catch (e) {
      print('지역 정보 로드 오류: $e');
      return [];
    }
  }

  // 특정 location이 어느 지역에 속하는지 확인
  Future<String?> findRegionByLocation(String location) async {
    try {
      final querySnapshot = await _firestore.collection('regions').get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final schools = data['schools'] as List<dynamic>? ?? [];
        final schoolNames = schools.map((school) => school['name'] ?? '').toList();
        
        if (schoolNames.contains(location)) {
          return doc.id;
        }
      }
      return null; // 기존에 없는 location
    } catch (e) {
      print('지역 검색 오류: $e');
      return null;
    }
  }

  // 새로운 location을 기존 지역에 추가
  Future<bool> addLocationToRegion(String regionId, String location) async {
    try {
      // 새 학교를 schools 배열에 추가 (관리자 검토 필요)
      await _firestore.collection('regions').doc(regionId).update({
        'schools': FieldValue.arrayUnion([{
          'name': location,
          'description': '', // 빈 설명
          'image': '', // 빈 이미지 (나중에 코스 이미지에서 가져올 예정)
          'isChecked': false, // 관리자 검토 필요
        }])
      });
      return true;
    } catch (e) {
      print('location 추가 오류: $e');
      return false;
    }
  }

  // 지역명으로 지역 찾기
  Future<String?> findRegionByName(String regionName) async {
    try {
      final querySnapshot = await _firestore.collection('regions').get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['regionName'] == regionName) {
          return doc.id; // 문서 ID 반환
        }
      }
      return null; // 해당 지역명이 없음
    } catch (e) {
      print('지역명 검색 오류: $e');
      return null;
    }
  }

  // 새로운 지역 생성 (Firebase 자동 ID 사용)
  Future<bool> createRegion(String regionName, String location) async {
    try {
      await _firestore.collection('regions').add({
        'regionName': regionName,
        'schools': [{
          'name': location,
          'description': '', // 빈 설명
          'image': '', // 빈 이미지 (나중에 코스 이미지에서 가져올 예정)
          'isChecked': false, // 관리자 검토 필요
        }]
      });
      return true;
    } catch (e) {
      print('새 지역 생성 오류: $e');
      return false;
    }
  }

  // 지역의 학교 상세 정보 가져오기
  Future<List<Map<String, dynamic>>> getSchoolsByRegion(String regionId) async {
    try {
      final doc = await _firestore.collection('regions').doc(regionId).get();
      
      if (!doc.exists) {
        return [];
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final schools = data['schools'] as List<dynamic>? ?? [];
      
      return schools.map<Map<String, dynamic>>((school) => {
        'name': school['name'] ?? '',
        'description': school['description'] ?? '',
        'image': school['image'] ?? '',
        'isChecked': school['isChecked'] ?? false, // 기본값은 false
      }).toList();
    } catch (e) {
      print('RegionService: 학교 정보 로드 오류: $e');
      return [];
    }
  }

  // 지역에 학교 상세 정보 업데이트 (설명, 이미지 포함)
  Future<bool> updateRegionWithSchools(String regionName, List<Map<String, dynamic>> schools) async {
    try {
      await _firestore.collection('regions').add({
        'regionName': regionName,
        'schools': schools.map((school) => {
          'name': school['name'],
          'description': school['description'],
          'image': school['image'],
          'isChecked': school['isChecked'] ?? true, // 기본값은 true (기존 데이터)
        }).toList(),
      });
      return true;
    } catch (e) {
      print('지역 학교 정보 업데이트 오류: $e');
      return false;
    }
  }

  // 서울 지역의 하드코딩된 학교 데이터 업로드
  Future<bool> uploadSeoulSchoolsData() async {
    final seoulSchools = [
      {
        "name": "동국대학교", 
        "image": "assets/images/dongguk2.jpg", 
        "description": "남산 자락에 위치한 전통과 현대가 어우러진 캠퍼스. 도심 속에서도 조용하고 여유로운 분위기를 느낄 수 있어요.",
        "isChecked": true, // 관리자 검토 완료
      },
      {
        "name": "연세대학교", 
        "image": "assets/images/yonsei.jpg", 
        "description": "신촌의 위치로 복잡하지만 분위기 좋고 산책도 가능.",
        "isChecked": true, // 관리자 검토 완료
      },
      {
        "name": "홍익대학교", 
        "image": "assets/images/honggik.jpg", 
        "description": "예술적인 감성이 가득한 캠퍼스. 개성있는 데이트 코스로 추천.",
        "isChecked": true, // 관리자 검토 완료
      },
      {
        "name": "성균관대학교", 
        "image": "assets/images/sung.jpg", 
        "description": "조용하고 전통이 있는 분위기. 조경이 잘 되어 있어 여유롭게 걷기 좋아요.",
        "isChecked": true, // 관리자 검토 완료
      },
      {
        "name": "건국대학교", 
        "image": "assets/images/konkuk.jpg", 
        "description": "호수와 캠퍼스가 어우러져 분위기 최고! 넓고 쾌적한 캠퍼스로 산책 코스로 추천.",
        "isChecked": true, // 관리자 검토 완료
      },
    ];

    return await updateRegionWithSchools("서울", seoulSchools);
  }

  // 관리자 미검토 학교들의 이미지를 해당 학교 최고 조회수 코스 이미지로 설정
  Future<List<Map<String, dynamic>>> getSchoolsWithDynamicImages(String regionId) async {
    try {
      final schools = await getSchoolsByRegion(regionId);
      
      for (var school in schools) {
        // isChecked가 false이고 이미지가 비어있는 경우
        if (school['isChecked'] == false && 
            (school['image'] == null || school['image'].toString().isEmpty)) {
          
          // 해당 학교의 가장 조회수 높은 코스 이미지 가져오기
          final courseImage = await _courseService.getMostViewedCourseImageBySchool(school['name']);
          
          if (courseImage.isNotEmpty) {
            school['image'] = courseImage;
          } else {
            // 코스가 없으면 기본 이미지 사용
            school['image'] = 'assets/images/nothing.png';
          }
        }
      }
      
      return schools;
    } catch (e) {
      print('RegionService: 동적 이미지 로드 오류: $e');
      return [];
    }
  }
}

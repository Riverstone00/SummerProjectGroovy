import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Firebase 초기화
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  try {
    print('서울 region 데이터 업로드 시작...');
    
    // 서울 region 생성
    final regionDoc = await firestore.collection('regions').add({
      'regionName': '서울',
      'schools': [
        {
          'name': '동국대학교',
          'description': '남산 자락에 위치한 전통과 현대가 어우러진 캠퍼스. 도심 속에서도 조용하고 여유로운 분위기를 느낄 수 있어요.',
          'image': '',
          'isChecked': true,
        },
        {
          'name': '연세대학교', 
          'description': '신촌의 위치로 복잡하지만 분위기 좋고 산책도 가능.',
          'image': '',
          'isChecked': true,
        },
        {
          'name': '홍익대학교',
          'description': '예술적인 감성이 가득한 캠퍼스. 개성있는 데이트 코스로 추천.',
          'image': '',
          'isChecked': true,
        },
        {
          'name': '성균관대학교',
          'description': '조용하고 전통이 있는 분위기. 조경이 잘 되어 있어 여유롭게 걷기 좋아요.',
          'image': '',
          'isChecked': true,
        },
        {
          'name': '건국대학교',
          'description': '호수와 캠퍼스가 어우러져 분위기 최고! 넓고 쾌적한 캠퍼스로 산책 코스로 추천.',
          'image': '',
          'isChecked': true,
        },
      ],
    });
    
    print('서울 region 생성됨: ${regionDoc.id}');
    
    // 기존 지역들도 확인
    final regions = await firestore.collection('regions').get();
    print('현재 총 ${regions.docs.length}개 region 존재');
    
    for (var region in regions.docs) {
      final data = region.data();
      final schools = data['schools'] as List? ?? [];
      print('Region ${region.id} (${data['regionName']}): ${schools.length}개 학교');
    }
    
  } catch (e) {
    print('오류 발생: $e');
  }
}

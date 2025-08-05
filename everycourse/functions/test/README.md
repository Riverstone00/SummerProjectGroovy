# Firebase Functions 테스트 데이터

EveryCourse 프로젝트의 Firebase Functions 테스트를 위한 데이터입니다.

## 파일 구조

```
test/
├── test-data.json      # 코스 데이터 (해시태그 포함)
├── users-data.json     # 사용자 데이터  
├── likes-data.json     # 좋아요 데이터
├── reviews-data.json   # 리뷰 데이터
├── upload-test-data.sh # Linux/Mac 업로드 스크립트
├── upload-test-data.bat # Windows 업로드 스크립트
└── README.md          # 이 파일
```

## 테스트 데이터 업로드 방법

### 방법 1: Firebase Console 사용
1. [Firebase Console](https://console.firebase.google.com/project/everycourse-911af/firestore) 접속
2. 각 JSON 파일의 내용을 복사해서 수동으로 추가

### 방법 2: Firebase CLI 사용 (준비 중)
```bash
# 전체 업로드
firebase firestore:import test/

# 개별 업로드
firebase firestore:import test/test-data.json
firebase firestore:import test/users-data.json
firebase firestore:import test/likes-data.json  
firebase firestore:import test/reviews-data.json
```

## 자동 트리거되는 Functions

데이터를 업로드하면 다음 Functions가 자동으로 실행됩니다:

1. **createUserProfile** - 사용자 생성 시
   - 사용자 통계 초기화
   - 프로필 설정

2. **onCourseCreated** - 코스 생성 시  
   - 해시태그 기반 검색 인덱스 생성
   - 검색 키워드 자동 추출

3. **onLikeAdded** - 좋아요 추가 시
   - 코스 좋아요 수 자동 증가
   - 사용자 통계 업데이트

4. **onReviewAdded** - 리뷰 추가 시
   - 코스 평균 평점 자동 계산
   - 리뷰 수 업데이트

5. **onLikeRemoved** - 좋아요 삭제 시
   - 코스 좋아요 수 자동 감소

## 테스트 확인 방법

1. Firebase Console의 Functions 로그 확인
2. Firestore의 searchIndex 컬렉션 확인 (자동 생성)
3. 코스 문서의 likeCount, averageRating 필드 확인
4. 사용자 문서의 통계 필드 확인

## 해시태그 검색 테스트

테스트 데이터에 포함된 해시태그:
- `#강남데이트`, `#로맨틱`, `#저녁식사`, `#카페`, `#야경`
- `#홍대`, `#클럽`, `#술집`, `#젊은`, `#신나는`  
- `#한강`, `#산책`, `#자연`, `#피크닉`, `#여유`

이 해시태그들로 검색 기능을 테스트할 수 있습니다.

@echo off
echo EveryCourse Firebase Functions 테스트 데이터 업로드 시작...
echo.

echo 1. 사용자 데이터 업로드 중...
firebase firestore:import users-data.json

echo 2. 코스 데이터 업로드 중...
firebase firestore:import test-data.json

echo 3. 좋아요 데이터 업로드 중...
firebase firestore:import likes-data.json

echo 4. 리뷰 데이터 업로드 중...
firebase firestore:import reviews-data.json

echo.
echo 테스트 데이터 업로드 완료!
echo.
echo 다음 Functions가 자동으로 트리거됩니다:
echo - createUserProfile: 사용자 생성 시
echo - onCourseCreated: 코스 생성 시 (해시태그 기반 검색 인덱스 생성)
echo - onLikeAdded: 좋아요 추가 시 (좋아요 수 자동 업데이트)
echo - onReviewAdded: 리뷰 추가 시 (평균 평점 자동 계산)
echo.
echo Firebase Console에서 결과를 확인하세요:
echo https://console.firebase.google.com/project/everycourse-911af/firestore

pause

@echo off
echo 사용자 데이터 추가 중...

firebase firestore:write users/user-001 "{\"email\": \"test1@example.com\", \"displayName\": \"김철수\", \"age\": 25, \"gender\": \"male\", \"interests\": [\"데이트\", \"카페\", \"영화\"]}"

firebase firestore:write users/user-002 "{\"email\": \"test2@example.com\", \"displayName\": \"이영희\", \"age\": 23, \"gender\": \"female\", \"interests\": [\"쇼핑\", \"맛집\", \"여행\"]}"

echo 코스 데이터 추가 중...

firebase firestore:write courses/test-course-hashtag "{\"title\": \"강남 로맨틱 데이트 코스\", \"hashtags\": [\"#강남데이트\", \"#로맨틱\", \"#저녁식사\", \"#카페\", \"#야경\"], \"location\": \"강남구\", \"category\": \"데이트\", \"placeId\": \"place-001\", \"description\": \"강남에서 즐기는 로맨틱한 저녁 데이트 코스\"}"

echo 좋아요 데이터 추가 중...

firebase firestore:write likes/like-001 "{\"userId\": \"user-001\", \"courseId\": \"test-course-hashtag\"}"

firebase firestore:write likes/like-002 "{\"userId\": \"user-002\", \"courseId\": \"test-course-hashtag\"}"

echo 리뷰 데이터 추가 중...

firebase firestore:write reviews/review-001 "{\"userId\": \"user-001\", \"courseId\": \"test-course-hashtag\", \"rating\": 5, \"comment\": \"정말 로맨틱한 코스였어요! 추천합니다\"}"

echo 완료! Firebase Functions가 자동으로 트리거됩니다.
pause

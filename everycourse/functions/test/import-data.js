const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Firebase Admin 초기화
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'everycourse-911af'
  });
}

const db = admin.firestore();

async function importData() {
  console.log('🚀 Firebase Firestore 데이터 업로드 시작...\n');

  try {
    // 1. Users 데이터 업로드
    console.log('👥 사용자 데이터 업로드 중...');
    const usersData = JSON.parse(fs.readFileSync(path.join(__dirname, 'users-data.json'), 'utf8'));
    
    for (const [userId, userData] of Object.entries(usersData.users)) {
      await db.collection('users').doc(userId).set({
        ...userData,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`✅ 사용자 ${userId} 생성됨`);
    }

    // 2. Courses 데이터 업로드
    console.log('\n📚 코스 데이터 업로드 중...');
    const coursesData = JSON.parse(fs.readFileSync(path.join(__dirname, 'test-data.json'), 'utf8'));
    
    for (const [courseId, courseData] of Object.entries(coursesData.courses)) {
      await db.collection('courses').doc(courseId).set({
        ...courseData,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`✅ 코스 ${courseId} 생성됨`);
    }

    // 3. Likes 데이터 업로드
    console.log('\n❤️ 좋아요 데이터 업로드 중...');
    const likesData = JSON.parse(fs.readFileSync(path.join(__dirname, 'likes-data.json'), 'utf8'));
    
    for (const [likeId, likeData] of Object.entries(likesData.likes)) {
      await db.collection('likes').doc(likeId).set({
        ...likeData,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`✅ 좋아요 ${likeId} 생성됨`);
    }

    // 4. Reviews 데이터 업로드
    console.log('\n⭐ 리뷰 데이터 업로드 중...');
    const reviewsData = JSON.parse(fs.readFileSync(path.join(__dirname, 'reviews-data.json'), 'utf8'));
    
    for (const [reviewId, reviewData] of Object.entries(reviewsData.reviews)) {
      await db.collection('reviews').doc(reviewId).set({
        ...reviewData,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`✅ 리뷰 ${reviewId} 생성됨`);
    }

    console.log('\n🎉 모든 테스트 데이터 업로드 완료!');
    console.log('\n📊 자동으로 트리거된 Functions:');
    console.log('- createUserProfile: 사용자 프로필 생성');
    console.log('- onCourseCreated: 해시태그 기반 검색 인덱스 생성');
    console.log('- onLikeAdded: 좋아요 수 자동 계산');
    console.log('- onReviewAdded: 평균 평점 자동 계산');
    console.log('\n🔗 결과 확인: https://console.firebase.google.com/project/everycourse-911af/firestore');

  } catch (error) {
    console.error('❌ 데이터 업로드 실패:', error);
  }
}

// 스크립트 실행
importData();

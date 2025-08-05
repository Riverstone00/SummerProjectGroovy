import { onDocumentCreated, onDocumentDeleted } from 'firebase-functions/v2/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import { CourseService } from './services/courseService';
import { UserService } from './services/userService';
import { UtilityService } from './services/utilityService';
import { StudentVerificationService } from './services/StudentVerificationService';

// Global options
setGlobalOptions({ maxInstances: 10 });

// Firebase Admin SDK 초기화
admin.initializeApp();

const courseService = new CourseService();
const userService = new UserService();
const utilityService = new UtilityService();
const studentVerificationService = new StudentVerificationService();

// 1. 좋아요 추가 시 트리거
export const onLikeAdded = onDocumentCreated('likes/{likeId}', async (event) => {
  const likeData = event.data?.data();
  if (!likeData) return;
  
  const courseId = likeData.courseId;
  
  try {
    await courseService.updateLikeCount(courseId, 1);
    console.log(`Course ${courseId} like count increased`);
  } catch (error) {
    console.error('Error updating like count:', error);
  }
});

// 2. 좋아요 제거 시 트리거
export const onLikeRemoved = onDocumentDeleted('likes/{likeId}', async (event) => {
  const likeData = event.data?.data();
  if (!likeData) return;
  
  const courseId = likeData.courseId;
  
  try {
    await courseService.updateLikeCount(courseId, -1);
    console.log(`Course ${courseId} like count decreased`);
  } catch (error) {
    console.error('Error updating like count:', error);
  }
});

// 3. 리뷰 추가 시 트리거
export const onReviewAdded = onDocumentCreated('reviews/{reviewId}', async (event) => {
  const reviewData = event.data?.data();
  if (!reviewData) return;
  
  const courseId = reviewData.courseId;
  
  try {
    await courseService.updateAverageRating(courseId);
    console.log(`Course ${courseId} rating updated`);
  } catch (error) {
    console.error('Error updating course rating:', error);
  }
});

// 4. 새 사용자 생성 후 프로필 초기화
export const createUserProfile = onDocumentCreated('users/{userId}', async (event) => {
  const userData = event.data?.data();
  if (!userData) return;
  
  const userId = event.params.userId;
  const userEmail = userData.email;
  
  try {
    console.log(`User profile document created for ${userId}`);
    
    // 사용자 프로필 초기화
    await userService.updateUserStats(userId, 'profileViews', 0);
    
    // 학생 상태 초기화 (모든 사용자는 일반 사용자로 시작)
    if (userEmail) {
      await studentVerificationService.updateStudentStatus(userId);
      console.log(`User ${userId} initialized as regular user`);
    }
    
  } catch (error) {
    console.error('Error initializing user profile:', error);
  }
});

// 5. 코스 생성 시 검색 인덱스 업데이트
export const onCourseCreated = onDocumentCreated('courses/{courseId}', async (event) => {
  const courseData = event.data?.data();
  if (!courseData) return;
  
  const courseId = event.params.courseId;
  
  try {
    await utilityService.updateSearchIndex(courseId, courseData);
    console.log(`Search index updated for course ${courseId}`);
  } catch (error) {
    console.error('Error updating search index:', error);
  }
});

// HTTP API Functions for Student Verification

// 6. 테스트 사용자 생성 API
export const createTestUser = onRequest(async (req, res) => {
  // CORS 설정
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { userId, email, displayName } = req.body;

    if (!userId || !email || !displayName) {
      res.status(400).json({
        success: false,
        message: 'userId, email, displayName은 필수입니다.'
      });
      return;
    }

    // Firestore에 사용자 문서 생성 (이것이 createUserProfile 트리거를 실행함)
    await admin.firestore().collection('users').doc(userId).set({
      email,
      displayName,
      age: 22,
      gender: 'unknown',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({
      success: true,
      message: `사용자 ${userId}가 생성되었습니다. createUserProfile 트리거가 실행됩니다.`
    });

  } catch (error) {
    console.error('Error in createTestUser:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 7. 학생 인증 신청 API
export const requestStudentVerification = onRequest(async (req, res) => {
  // CORS 설정
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { userId, universityEmail } = req.body;

    if (!userId || !universityEmail) {
      res.status(400).json({
        success: false,
        message: 'userId와 universityEmail은 필수입니다.'
      });
      return;
    }

    const result = await studentVerificationService.requestStudentVerification(userId, universityEmail);
    res.json(result);

  } catch (error) {
    console.error('Error in requestStudentVerification:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 7. 이메일 인증 완료 API
export const verifyStudentEmail = onRequest(async (req, res) => {
  // CORS 설정
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { userId, token } = req.body;

    if (!userId || !token) {
      res.status(400).json({
        success: false,
        message: 'userId와 token은 필수입니다.'
      });
      return;
    }

    const result = await studentVerificationService.verifyEmail(userId, token);
    res.json(result);

  } catch (error) {
    console.error('Error in verifyStudentEmail:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 8. 학생 인증 상태 확인 API
export const checkStudentStatus = onRequest(async (req, res) => {
  // CORS 설정
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const userId = req.query.userId as string;

    if (!userId) {
      res.status(400).json({
        success: false,
        message: 'userId는 필수입니다.'
      });
      return;
    }

    const isVerified = await studentVerificationService.isVerifiedStudent(userId);
    res.json({
      success: true,
      isStudent: isVerified
    });

  } catch (error) {
    console.error('Error in checkStudentStatus:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 기존 주석들은 제거
// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

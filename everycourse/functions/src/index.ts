import { onDocumentCreated, onDocumentDeleted } from 'firebase-functions/v2/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import { CourseService } from './services/courseService';
import { UserService } from './services/userService';
import { UtilityService } from './services/utilityService';

// Global options
setGlobalOptions({ maxInstances: 10 });

// Firebase Admin SDK 초기화
admin.initializeApp();

const courseService = new CourseService();
const userService = new UserService();
const utilityService = new UtilityService();

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

// 4. 새 사용자 생성 후 프로필 생성
export const createUserProfile = onDocumentCreated('users/{userId}', async (event) => {
  const userData = event.data?.data();
  if (!userData) return;
  
  const userId = event.params.userId;
  
  try {
    console.log(`User profile document created for ${userId}`);
    // 사용자 프로필이 이미 생성되었으므로 추가 초기화 작업만 수행
    await userService.updateUserStats(userId, 'profileViews', 0); // 초기화
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
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

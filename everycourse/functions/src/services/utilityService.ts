import * as admin from 'firebase-admin';

export class UtilityService {
  private db = admin.firestore();

  /**
   * 검색 인덱스를 업데이트합니다
   */
  async updateSearchIndex(courseId: string, courseData: any): Promise<void> {
    try {
      const searchRef = this.db.collection('searchIndex').doc(courseId);
      
      // 검색용 키워드 생성
      const searchKeywords = this.generateSearchKeywords(courseData);
      
      const searchIndex = {
        courseId,
        title: courseData.title || '',
        description: courseData.description || '',
        tags: courseData.tags || [],
        location: courseData.location || '',
        category: courseData.category || '',
        keywords: searchKeywords,
        createdAt: courseData.createdAt || admin.firestore.FieldValue.serverTimestamp(),
        lastIndexed: admin.firestore.FieldValue.serverTimestamp()
      };
      
      await searchRef.set(searchIndex);
      console.log(`Search index updated for course ${courseId}`);
    } catch (error) {
      console.error(`Error updating search index for ${courseId}:`, error);
      throw error;
    }
  }

  /**
   * 검색용 키워드를 생성합니다
   */
  private generateSearchKeywords(courseData: any): string[] {
    const keywords = new Set<string>();
    
    // 제목에서 키워드 추출
    if (courseData.title) {
      const titleWords = courseData.title.toLowerCase().split(/\s+/);
      titleWords.forEach((word: string) => {
        if (word.length > 1) {
          keywords.add(word);
        }
      });
    }
    
    // 설명에서 키워드 추출
    if (courseData.description) {
      const descWords = courseData.description.toLowerCase().split(/\s+/);
      descWords.forEach((word: string) => {
        if (word.length > 2) {
          keywords.add(word);
        }
      });
    }
    
    // 태그 추가
    if (courseData.tags && Array.isArray(courseData.tags)) {
      courseData.tags.forEach((tag: string) => {
        keywords.add(tag.toLowerCase());
      });
    }
    
    // 위치 정보 추가
    if (courseData.location) {
      keywords.add(courseData.location.toLowerCase());
    }
    
    return Array.from(keywords);
  }

  /**
   * 알림을 전송합니다
   */
  async sendNotification(userId: string, title: string, body: string, data?: any): Promise<void> {
    try {
      const notificationRef = this.db.collection('notifications').doc();
      
      const notification = {
        userId,
        title,
        body,
        data: data || {},
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        type: data?.type || 'general'
      };
      
      await notificationRef.set(notification);
      
      // FCM으로 푸시 알림 전송 (토큰이 있는 경우)
      const userDoc = await this.db.collection('users').doc(userId).get();
      const userData = userDoc.data();
      
      if (userData?.fcmToken) {
        const message = {
          token: userData.fcmToken,
          notification: {
            title,
            body
          },
          data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : {}
        };
        
        try {
          await admin.messaging().send(message);
          console.log(`Push notification sent to user ${userId}`);
        } catch (pushError) {
          console.error(`Error sending push notification to ${userId}:`, pushError);
        }
      }
      
      console.log(`Notification saved for user ${userId}: ${title}`);
    } catch (error) {
      console.error(`Error sending notification to ${userId}:`, error);
      throw error;
    }
  }

  /**
   * 데이터 정리 작업을 수행합니다
   */
  async cleanupOldData(): Promise<void> {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      // 오래된 알림 삭제
      const oldNotifications = await this.db
        .collection('notifications')
        .where('createdAt', '<', thirtyDaysAgo)
        .where('isRead', '==', true)
        .limit(100)
        .get();
      
      const batch = this.db.batch();
      let deleteCount = 0;
      
      oldNotifications.forEach((doc) => {
        batch.delete(doc.ref);
        deleteCount++;
      });
      
      if (deleteCount > 0) {
        await batch.commit();
        console.log(`Deleted ${deleteCount} old notifications`);
      }
      
      // 오래된 로그 정리 (필요시 추가)
      
    } catch (error) {
      console.error('Error during cleanup:', error);
      throw error;
    }
  }

  /**
   * 통계 데이터를 생성합니다
   */
  async generateDailyStats(): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      // 오늘 생성된 코스 수
      const todayCoursesSnapshot = await this.db
        .collection('courses')
        .where('createdAt', '>=', today)
        .where('createdAt', '<', tomorrow)
        .get();
      
      // 오늘 가입한 사용자 수
      const todayUsersSnapshot = await this.db
        .collection('users')
        .where('createdAt', '>=', today)
        .where('createdAt', '<', tomorrow)
        .get();
      
      // 통계 저장
      const statsRef = this.db.collection('dailyStats').doc(today.toISOString().split('T')[0]);
      
      const stats = {
        date: today,
        coursesCreated: todayCoursesSnapshot.size,
        usersRegistered: todayUsersSnapshot.size,
        generatedAt: admin.firestore.FieldValue.serverTimestamp()
      };
      
      await statsRef.set(stats);
      console.log(`Daily stats generated for ${today.toISOString().split('T')[0]}:`, stats);
    } catch (error) {
      console.error('Error generating daily stats:', error);
      throw error;
    }
  }

  /**
   * 사용자 매칭을 위한 추천 알고리즘
   */
  async generateCourseRecommendations(userId: string, limit: number = 10): Promise<string[]> {
    try {
      // 사용자 선호도 분석
      const { UserService } = await import('./userService.js');
      const userService = new UserService();
      const userPreferences = await userService.analyzeUserPreferences(userId);
      
      if (userPreferences.preferences.length === 0) {
        // 선호도가 없으면 인기 코스 추천
        const popularCoursesSnapshot = await this.db
          .collection('courses')
          .orderBy('likeCount', 'desc')
          .orderBy('averageRating', 'desc')
          .limit(limit)
          .get();
        
        const recommendations: string[] = [];
        popularCoursesSnapshot.forEach((doc) => {
          recommendations.push(doc.id);
        });
        
        return recommendations;
      }
      
      // 선호 태그 기반 추천
      const preferredTags = userPreferences.preferences.slice(0, 3).map((pref: any) => pref[0]);
      const recommendedCoursesSnapshot = await this.db
        .collection('courses')
        .where('tags', 'array-contains-any', preferredTags)
        .orderBy('averageRating', 'desc')
        .limit(limit * 2) // 필터링을 위해 더 많이 가져옴
        .get();
      
      // 이미 좋아요한 코스 제외
      const userLikesSnapshot = await this.db
        .collection('likes')
        .where('userId', '==', userId)
        .get();
      
      const likedCourseIds = new Set<string>();
      userLikesSnapshot.forEach((doc) => {
        const like = doc.data();
        likedCourseIds.add(like.courseId);
      });
      
      const recommendations: string[] = [];
      recommendedCoursesSnapshot.forEach((doc) => {
        if (!likedCourseIds.has(doc.id) && recommendations.length < limit) {
          recommendations.push(doc.id);
        }
      });
      
      console.log(`Generated ${recommendations.length} recommendations for user ${userId}`);
      return recommendations;
    } catch (error) {
      console.error(`Error generating recommendations for ${userId}:`, error);
      throw error;
    }
  }
}
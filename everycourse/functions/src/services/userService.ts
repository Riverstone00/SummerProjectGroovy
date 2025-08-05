import * as admin from 'firebase-admin';

export class UserService {
  private db = admin.firestore();

  /**
   * 새 사용자 프로필을 생성합니다
   */
  async createUserProfile(uid: string, userData: any): Promise<void> {
    try {
      const userRef = this.db.collection('users').doc(uid);
      
      const userProfile = {
        uid,
        email: userData.email || '',
        displayName: userData.displayName || '',
        profileImage: userData.profileImage || '',
        university: userData.university || '',
        major: userData.major || '',
        grade: userData.grade || 1,
        gender: userData.gender || '',
        birthYear: userData.birthYear || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
        isActive: true,
        preferences: {
          notifications: true,
          privateProfile: false,
          ageRange: '20-25'
        },
        stats: {
          coursesCreated: 0,
          coursesLiked: 0,
          reviewsWritten: 0,
          profileViews: 0
        }
      };
      
      await userRef.set(userProfile);
      console.log(`User profile created for ${uid}`);
    } catch (error) {
      console.error(`Error creating user profile for ${uid}:`, error);
      throw error;
    }
  }

  /**
   * 사용자 통계를 업데이트합니다
   */
  async updateUserStats(uid: string, statType: 'coursesCreated' | 'coursesLiked' | 'reviewsWritten' | 'profileViews', increment: number = 1): Promise<void> {
    try {
      const userRef = this.db.collection('users').doc(uid);
      
      await this.db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw new Error(`User ${uid} does not exist`);
        }
        
        const currentData = userDoc.data();
        const currentStats = currentData?.stats || {};
        const currentValue = currentStats[statType] || 0;
        
        transaction.update(userRef, {
          [`stats.${statType}`]: Math.max(0, currentValue + increment),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      
      console.log(`Updated ${statType} for user ${uid}: ${increment > 0 ? '+' : ''}${increment}`);
    } catch (error) {
      console.error(`Error updating user stats for ${uid}:`, error);
      throw error;
    }
  }

  /**
   * 사용자의 마지막 로그인 시간을 업데이트합니다
   */
  async updateLastLogin(uid: string): Promise<void> {
    try {
      const userRef = this.db.collection('users').doc(uid);
      
      await userRef.update({
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`Updated last login for user ${uid}`);
    } catch (error) {
      console.error(`Error updating last login for ${uid}:`, error);
      throw error;
    }
  }

  /**
   * 비활성 사용자를 찾습니다 (30일 이상 로그인하지 않은 사용자)
   */
  async findInactiveUsers(): Promise<string[]> {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const inactiveUsersSnapshot = await this.db
        .collection('users')
        .where('lastLoginAt', '<', thirtyDaysAgo)
        .where('isActive', '==', true)
        .get();
      
      const inactiveUserIds: string[] = [];
      inactiveUsersSnapshot.forEach((doc) => {
        inactiveUserIds.push(doc.id);
      });
      
      console.log(`Found ${inactiveUserIds.length} inactive users`);
      return inactiveUserIds;
    } catch (error) {
      console.error('Error finding inactive users:', error);
      throw error;
    }
  }

  /**
   * 사용자 매칭 알고리즘을 위한 선호도 분석
   */
  async analyzeUserPreferences(uid: string): Promise<any> {
    try {
      // 사용자가 좋아요한 코스들 분석
      const likesSnapshot = await this.db
        .collection('likes')
        .where('userId', '==', uid)
        .get();
      
      const likedCourseIds: string[] = [];
      likesSnapshot.forEach((doc) => {
        const like = doc.data();
        likedCourseIds.push(like.courseId);
      });
      
      if (likedCourseIds.length === 0) {
        return { preferences: [], confidence: 0 };
      }
      
      // 좋아요한 코스들의 태그/카테고리 분석
      const coursesSnapshot = await this.db
        .collection('courses')
        .where(admin.firestore.FieldPath.documentId(), 'in', likedCourseIds.slice(0, 10)) // Firestore 제한으로 최대 10개
        .get();
      
      const preferences: { [key: string]: number } = {};
      
      coursesSnapshot.forEach((doc) => {
        const course = doc.data();
        const tags = course.tags || [];
        
        tags.forEach((tag: string) => {
          preferences[tag] = (preferences[tag] || 0) + 1;
        });
      });
      
      console.log(`Analyzed preferences for user ${uid}:`, preferences);
      return { 
        preferences: Object.entries(preferences).sort((a, b) => b[1] - a[1]),
        confidence: Math.min(likedCourseIds.length / 10, 1) // 최대 1.0
      };
    } catch (error) {
      console.error(`Error analyzing preferences for user ${uid}:`, error);
      throw error;
    }
  }
}

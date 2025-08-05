import * as admin from 'firebase-admin';

export class CourseService {
  private db = admin.firestore();

  /**
   * 코스의 좋아요 수를 업데이트합니다
   */
  async updateLikeCount(courseId: string, increment: number): Promise<void> {
    const courseRef = this.db.collection('courses').doc(courseId);
    
    try {
      await this.db.runTransaction(async (transaction) => {
        const courseDoc = await transaction.get(courseRef);
        
        if (!courseDoc.exists) {
          throw new Error(`Course ${courseId} does not exist`);
        }
        
        const currentData = courseDoc.data();
        const currentLikes = currentData?.likeCount || 0;
        const newLikeCount = Math.max(0, currentLikes + increment);
        
        transaction.update(courseRef, { 
          likeCount: newLikeCount,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      
      console.log(`Updated like count for course ${courseId}: ${increment > 0 ? '+' : ''}${increment}`);
    } catch (error) {
      console.error(`Error updating like count for course ${courseId}:`, error);
      throw error;
    }
  }

  /**
   * 코스의 평균 평점을 업데이트합니다
   */
  async updateAverageRating(courseId: string): Promise<void> {
    try {
      // 해당 코스의 모든 리뷰 가져오기
      const reviewsSnapshot = await this.db
        .collection('reviews')
        .where('courseId', '==', courseId)
        .get();
      
      if (reviewsSnapshot.empty) {
        // 리뷰가 없으면 평점을 0으로 설정
        await this.db.collection('courses').doc(courseId).update({
          averageRating: 0,
          reviewCount: 0,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        });
        return;
      }
      
      // 평균 평점 계산
      let totalRating = 0;
      let reviewCount = 0;
      
      reviewsSnapshot.forEach((doc) => {
        const review = doc.data();
        totalRating += review.rating || 0;
        reviewCount++;
      });
      
      const averageRating = totalRating / reviewCount;
      
      // 코스 문서 업데이트
      await this.db.collection('courses').doc(courseId).update({
        averageRating: Math.round(averageRating * 100) / 100, // 소수점 둘째자리까지
        reviewCount: reviewCount,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`Updated average rating for course ${courseId}: ${averageRating} (${reviewCount} reviews)`);
    } catch (error) {
      console.error(`Error updating average rating for course ${courseId}:`, error);
      throw error;
    }
  }

  /**
   * 인기 코스 순위를 업데이트합니다
   */
  async updatePopularityRanking(): Promise<void> {
    try {
      const coursesSnapshot = await this.db
        .collection('courses')
        .orderBy('likeCount', 'desc')
        .orderBy('averageRating', 'desc')
        .limit(100)
        .get();
      
      const batch = this.db.batch();
      let rank = 1;
      
      coursesSnapshot.forEach((doc) => {
        batch.update(doc.ref, { 
          popularityRank: rank,
          lastRankUpdated: admin.firestore.FieldValue.serverTimestamp()
        });
        rank++;
      });
      
      await batch.commit();
      console.log(`Updated popularity rankings for ${coursesSnapshot.size} courses`);
    } catch (error) {
      console.error('Error updating popularity rankings:', error);
      throw error;
    }
  }
}

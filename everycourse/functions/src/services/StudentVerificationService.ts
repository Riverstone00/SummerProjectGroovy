import * as admin from 'firebase-admin';

export class StudentVerificationService {
  private db = admin.firestore();

  /**
   * 학교 이메일 도메인 목록
   */
  private readonly universityDomains = [
    'ac.kr', // 한국 대학교 (.ac.kr로 끝나는 모든 도메인)
    'edu.kr', // 한국 교육기관 (.edu.kr로 끝나는 모든 도메인)
    'edu', // 미국 대학교 (.edu로 끝나는 모든 도메인)
    // 특정 대학교들
    'snu.ac.kr', // 서울대
    'yonsei.ac.kr', // 연세대
    'korea.ac.kr', // 고려대
    'kaist.ac.kr', // 카이스트
    'postech.ac.kr', // 포스텍
    'skku.edu', // 성균관대
    'hanyang.ac.kr', // 한양대
    // 필요에 따라 더 추가
  ];

  /**
   * 이메일이 학교 이메일인지 확인
   */
  isUniversityEmail(email: string): boolean {
    const domain = email.split('@')[1]?.toLowerCase();
    if (!domain) return false;

    return this.universityDomains.some((uniDomain) => 
      domain.endsWith(uniDomain)
    );
  }

  /**
   * 사용자 초기화 (모든 사용자는 일반 사용자로 시작)
   */
  async updateStudentStatus(userId: string): Promise<void> {
    try {
      // 모든 사용자는 처음에 일반 사용자로 시작
      await this.db.collection('users').doc(userId).update({
        isStudent: false,
        emailVerified: false,
        studentVerificationStatus: 'none', // none, pending, verified
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`User ${userId} initialized as regular user`);

    } catch (error) {
      console.error(`Error updating student status for ${userId}:`, error);
      throw error;
    }
  }

  /**
   * 학생 인증 신청
   */
  async requestStudentVerification(userId: string, universityEmail: string): Promise<{ success: boolean, message: string }> {
    try {
      // 1. 학교 이메일 형식 확인
      if (!this.isUniversityEmail(universityEmail)) {
        return {
          success: false,
          message: '유효한 학교 이메일이 아닙니다. .ac.kr 또는 .edu.kr로 끝나는 이메일을 입력해주세요.'
        };
      }

      // 2. 사용자 상태 업데이트
      await this.db.collection('users').doc(userId).update({
        universityEmail,
        studentVerificationStatus: 'pending',
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });

      // 3. 인증 이메일 발송 (간단 버전)
      await this.sendVerificationEmail(userId, universityEmail);

      return {
        success: true,
        message: `${universityEmail}로 인증 이메일을 발송했습니다.`
      };

    } catch (error) {
      console.error(`Error requesting student verification for ${userId}:`, error);
      return { success: false, message: '인증 요청 중 오류가 발생했습니다.' };
    }
  }

  /**
   * 간단한 인증 이메일 발송 (로그만)
   */
  private async sendVerificationEmail(userId: string, email: string): Promise<void> {
    try {
      const verificationToken = this.generateVerificationToken();
      
      // 인증 정보 저장
      await this.db.collection('emailVerifications').doc(userId).set({
        userId,
        email,
        token: verificationToken,
        isVerified: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000)
      });

      // 인증 링크 (실제로는 이메일 발송)
      const verificationLink = `https://everycourse-911af.web.app/verify-student?token=${verificationToken}&userId=${userId}`;
      
      console.log(`📧 학생 인증 이메일 발송: ${email}`);
      console.log(`🔗 인증 링크: ${verificationLink}`);
      
    } catch (error) {
      console.error(`Error sending verification email:`, error);
      throw error;
    }
  }

  /**
   * 인증 토큰 생성
   */
  private generateVerificationToken(): string {
    return Math.random().toString(36).substring(2, 15) + Date.now().toString(36);
  }

  /**
   * 이메일 인증 완료 (간단 버전)
   */
  async verifyEmail(userId: string, token: string): Promise<{ success: boolean, message: string }> {
    try {
      const verificationDoc = await this.db.collection('emailVerifications').doc(userId).get();
      
      if (!verificationDoc.exists) {
        return { success: false, message: '인증 요청을 찾을 수 없습니다.' };
      }

      const verificationData = verificationDoc.data();
      if (!verificationData) {
        return { success: false, message: '인증 데이터를 찾을 수 없습니다.' };
      }
      
      if (verificationData.token !== token) {
        return { success: false, message: '잘못된 인증 토큰입니다.' };
      }

      if (new Date() > verificationData.expiresAt.toDate()) {
        return { success: false, message: '인증 토큰이 만료되었습니다.' };
      }

      // 학생 인증 완료! ✨
      await this.db.collection('users').doc(userId).update({
        isStudent: true, // 이것만 true로 바꾸면 됨!
        emailVerified: true,
        studentVerificationStatus: 'verified',
        verifiedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`🎓 Student verification completed for user ${userId}`);
      
      return { 
        success: true, 
        message: '학생 인증이 완료되었습니다! 이제 코스에 학생 마크가 표시됩니다.' 
      };

    } catch (error) {
      console.error(`Error verifying email:`, error);
      return { success: false, message: '인증 확인 중 오류가 발생했습니다.' };
    }
  }

  /**
   * 학생 인증 상태 확인 (코스에 마크 표시용)
   */
  async isVerifiedStudent(userId: string): Promise<boolean> {
    try {
      const userDoc = await this.db.collection('users').doc(userId).get();
      
      if (!userDoc.exists) return false;
      
      const userData = userDoc.data();
      if (!userData) return false;
      
      return userData.isStudent === true && userData.emailVerified === true;

    } catch (error) {
      console.error(`Error checking student status:`, error);
      return false;
    }
  }
}

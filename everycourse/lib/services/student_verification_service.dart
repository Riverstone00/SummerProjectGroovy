import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_service.dart';

class StudentVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 학교 이메일 도메인 목록
  final List<String> _universityDomains = [
    'ac.kr',
    'edu.kr',
    'edu',
    'snu.ac.kr',
    'yonsei.ac.kr',
    'korea.ac.kr',
    'kaist.ac.kr',
    'postech.ac.kr',
    'skku.edu',
    'hanyang.ac.kr',
    'dongguk.edu', // 동국대 추가
    // 필요에 따라 더 추가
  ];

  /// 이메일이 학교 이메일인지 확인
  bool isUniversityEmail(String email) {
    final domain = email.split('@').last.toLowerCase();
    return _universityDomains.any((uniDomain) => domain.endsWith(uniDomain));
  }

  /// 학생 인증 신청
  Future<Map<String, dynamic>> requestStudentVerification(
    String universityEmail,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': '로그인이 필요합니다.'};
      }

      // 1. 학교 이메일 형식 확인
      if (!isUniversityEmail(universityEmail)) {
        return {
          'success': false,
          'message': '유효한 학교 이메일이 아닙니다. .ac.kr 또는 .edu.kr로 끝나는 이메일을 입력해주세요.',
        };
      }

      // 2. 인증 토큰 생성
      final verificationToken = _generateVerificationToken();

      // 3. 사용자 문서 확인 및 생성/업데이트
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // 기존 사용자 - 업데이트
        await userDocRef.update({
          'universityEmail': universityEmail,
          'studentVerificationStatus': 'pending',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // 새 사용자 - 문서 생성
        await userDocRef.set({
          'email': user.email ?? '',
          'displayName': user.displayName ?? '사용자',
          'photoURL': user.photoURL ?? '',
          'universityEmail': universityEmail,
          'studentVerificationStatus': 'pending',
          'isStudent': false,
          'isStudentVerified': false,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // 4. 인증 정보 저장
      await _firestore.collection('emailVerifications').doc(user.uid).set({
        'userId': user.uid,
        'email': universityEmail,
        'token': verificationToken,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
      });

      // 5. 실제 이메일 발송 🚀
      final emailSent = await EmailService.sendVerificationEmail(
        recipientEmail: universityEmail,
        verificationToken: verificationToken,
        userId: user.uid,
      );

      if (!emailSent) {
        // 이메일 발송 실패시 로그 출력으로 대체
        final verificationLink =
            'https://everycourse-911af.web.app/verify-student?token=$verificationToken&userId=${user.uid}';
        print('📧 이메일 발송 실패 - 로그 출력: $universityEmail');
        print('🔗 인증 링크: $verificationLink');
      }

      return {
        'success': true,
        'message': emailSent
            ? '$universityEmail로 인증 이메일을 발송했습니다. 이메일을 확인해주세요!'
            : '$universityEmail로 인증 이메일 발송을 시도했습니다. (개발 모드)',
        'token': verificationToken, // 개발용으로 토큰 반환
      };
    } catch (e) {
      print('Error requesting student verification: $e');
      return {'success': false, 'message': '인증 요청 중 오류가 발생했습니다.'};
    }
  }

  /// 이메일 인증 완료
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': '로그인이 필요합니다.'};
      }

      final verificationDoc = await _firestore
          .collection('emailVerifications')
          .doc(user.uid)
          .get();

      if (!verificationDoc.exists) {
        return {'success': false, 'message': '인증 요청을 찾을 수 없습니다.'};
      }

      final verificationData = verificationDoc.data()!;

      if (verificationData['token'] != token) {
        return {'success': false, 'message': '잘못된 인증 토큰입니다.'};
      }

      final expiresAt = (verificationData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        return {'success': false, 'message': '인증 토큰이 만료되었습니다.'};
      }

      // 학생 인증 완료! ✨
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // 기존 사용자 - 업데이트
        await userDocRef.update({
          'isStudent': true,
          'isStudentVerified': true, // 마이페이지에서 사용하는 필드명
          'emailVerified': true,
          'studentVerificationStatus': 'verified',
          'verifiedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 새 사용자 - 문서 생성 (일반적으로는 이미 생성되어 있어야 함)
        await userDocRef.set({
          'email': user.email ?? '',
          'displayName': user.displayName ?? '사용자',
          'photoURL': user.photoURL ?? '',
          'isStudent': true,
          'isStudentVerified': true,
          'emailVerified': true,
          'studentVerificationStatus': 'verified',
          'createdAt': FieldValue.serverTimestamp(),
          'verifiedAt': FieldValue.serverTimestamp(),
        });
      }

      print('🎓 Student verification completed for user ${user.uid}');

      return {
        'success': true,
        'message': '학생 인증이 완료되었습니다! 이제 코스에 학생 마크가 표시됩니다.',
      };
    } catch (e) {
      print('Error verifying email: $e');
      return {'success': false, 'message': '인증 확인 중 오류가 발생했습니다.'};
    }
  }

  /// 학생 인증 상태 확인
  Future<bool> isVerifiedStudent() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;

      return userData['isStudent'] == true && userData['emailVerified'] == true;
    } catch (e) {
      print('Error checking student status: $e');
      return false;
    }
  }

  /// 인증 토큰 생성
  String _generateVerificationToken() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String token = '';
    for (int i = 0; i < 20; i++) {
      token +=
          chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length];
    }
    return token + random;
  }
}

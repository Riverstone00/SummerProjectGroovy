import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 사용자 프로필을 Firestore에 생성
  /// 이 함수가 실행되면 Firebase Functions의 createUserProfile 트리거가 실행됩니다
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // 이미 존재하는지 확인
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        // 기본 사용자 데이터
        final userData = {
          'email': email,
          'displayName': displayName ?? email.split('@')[0],
          'photoURL': photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          // 추가 데이터가 있으면 병합
          ...?additionalData,
        };

        // Firestore에 사용자 문서 생성
        // 이 작업이 Firebase Functions의 createUserProfile 트리거를 실행합니다
        await _firestore.collection('users').doc(userId).set(userData);
        
        print('✅ User profile created for $userId - createUserProfile trigger will run');
      } else {
        // 이미 존재하는 사용자의 마지막 로그인 시간 업데이트
        await _firestore.collection('users').doc(userId).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Existing user $userId logged in');
      }
    } catch (e) {
      print('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  /// 이메일/비밀번호 회원가입 + 프로필 생성
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print('🔄 Attempting signup for: $email');
      
      // 1. Firebase Auth로 사용자 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth signup successful for: $email');

      // 2. 사용자 정보가 있으면 프로필 업데이트
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      // 3. Firestore에 사용자 프로필 생성 (트리거 실행)
      if (credential.user != null) {
        await createUserProfile(
          userId: credential.user!.uid,
          email: email,
          displayName: displayName ?? credential.user!.displayName,
          photoURL: credential.user!.photoURL,
        );
      }

      return credential;
    } catch (e) {
      print('❌ Error in signUpWithEmailAndPassword: $e');
      if (e.toString().contains('operation-not-allowed')) {
        print('🚨 Firebase Authentication이 비활성화되어 있습니다!');
        print('🔧 Firebase 콘솔에서 Authentication > Sign-in method에서 Email/Password를 활성화해주세요.');
        print('🌐 URL: https://console.firebase.google.com/project/everycourse-911af/authentication/providers');
      }
      if (e.toString().contains('weak-password')) {
        print('🚨 비밀번호가 너무 약합니다! 최소 6자 이상 입력해주세요.');
      }
      rethrow;
    }
  }

  /// 이메일/비밀번호 로그인 + 프로필 동기화
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Attempting login for: $email');
      
      // 1. Firebase Auth로 로그인
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth login successful for: $email');

      // 2. Firestore 프로필 동기화 (없으면 생성, 있으면 업데이트)
      if (credential.user != null) {
        await createUserProfile(
          userId: credential.user!.uid,
          email: email,
          displayName: credential.user!.displayName,
          photoURL: credential.user!.photoURL,
        );
      }

      return credential;
    } catch (e) {
      print('❌ Error in signInWithEmailAndPassword: $e');
      if (e.toString().contains('operation-not-allowed')) {
        print('🚨 Firebase Authentication이 비활성화되어 있습니다!');
        print('🔧 Firebase 콘솔에서 Authentication > Sign-in method에서 Email/Password를 활성화해주세요.');
        print('🌐 URL: https://console.firebase.google.com/project/everycourse-911af/authentication/providers');
      }
      rethrow;
    }
  }

  /// 구글 로그인 + 프로필 생성
  Future<UserCredential> signInWithGoogle(AuthCredential credential) async {
    try {
      print('🔄 Attempting Firebase Google Sign-In...');
      
      // 1. Firebase Auth로 구글 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      print('✅ Firebase Google Sign-In successful for: ${userCredential.user?.email}');

      // 2. Firestore에 사용자 프로필 생성/업데이트 (트리거 실행)
      if (userCredential.user != null) {
        final user = userCredential.user!;
        print('🔄 Creating/updating user profile for: ${user.uid}');
        
        await createUserProfile(
          userId: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoURL: user.photoURL,
          additionalData: {
            'authProvider': 'google',
          },
        );
        
        print('✅ User profile created/updated successfully');
      }

      return userCredential;
    } catch (e) {
      print('❌ Error in signInWithGoogle: $e');
      if (e.toString().contains('operation-not-allowed')) {
        print('🚨 Google Sign-In이 Firebase 콘솔에서 비활성화되어 있습니다!');
        print('🔧 Firebase 콘솔 > Authentication > Sign-in method에서 Google을 활성화해주세요.');
      }
      rethrow;
    }
  }

  /// 익명 로그인 + 프로필 생성
  Future<UserCredential> signInAnonymously() async {
    try {
      // 1. Firebase Auth로 익명 로그인
      final credential = await _auth.signInAnonymously();

      // 2. Firestore에 익명 사용자 프로필 생성 (트리거 실행)
      if (credential.user != null) {
        await createUserProfile(
          userId: credential.user!.uid,
          email: 'anonymous@everycourse.com',
          displayName: '익명 사용자',
          additionalData: {
            'authProvider': 'anonymous',
          },
        );
      }

      return credential;
    } catch (e) {
      print('❌ Error in signInAnonymously: $e');
      rethrow;
    }
  }

  /// 현재 로그인된 사용자의 프로필 가져오기
  Future<DocumentSnapshot?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await _firestore.collection('users').doc(user.uid).get();
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore.collection('users').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// 로그아웃 (Google Sign-In 포함)
  Future<void> signOut() async {
    try {
      // Google Sign-In 로그아웃
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        print('✅ Google Sign-In logout successful');
      }
      
      // Firebase Auth 로그아웃
      await _auth.signOut();
      print('✅ Firebase Auth logout successful');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }
}

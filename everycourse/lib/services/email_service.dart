import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Gmail SMTP 설정 - 본인 Gmail 계정으로 변경하세요!
  static const String _senderEmail = 'nnnd518@gmail.com'; // 본인 Gmail 입력 완료!
  static const String _senderPassword =
      'gxuq scbg hhwl gaos'; // Gmail 앱 비밀번호 입력 완료!

  // 개발 모드 설정 (true: 개발 모드, false: 실제 이메일 발송)
  static const bool _isDevelopmentMode = false;

  /// 학생 인증 이메일 발송
  static Future<bool> sendVerificationEmail({
    required String recipientEmail,
    required String verificationToken,
    required String userId,
  }) async {
    try {
      // 개발 모드에서는 이메일을 실제로 보내지 않고 콘솔에 토큰 출력
      if (_isDevelopmentMode) {
        print('🔧 개발 모드: 이메일 발송 시뮬레이션');
        print('📧 수신자: $recipientEmail');
        print('🔑 인증 토큰: $verificationToken');
        print('💡 실제 앱에서는 이 토큰을 이메일로 받게 됩니다.');
        print('📱 개발자용: 토큰을 복사해서 인증 화면에 입력하세요!');
        return true;
      }
      // Gmail SMTP 서버 설정
      final smtpServer = gmail(_senderEmail, _senderPassword);

      // 이메일 메시지 작성
      final message = Message()
        ..from = Address(_senderEmail, 'EveryCourse')
        ..recipients.add(recipientEmail)
        ..subject = '🎓 EveryCourse 학생 인증 메일'
        ..html =
            '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #E91E63; font-size: 28px; margin-bottom: 10px;">🎓 EveryCourse</h1>
            <h2 style="color: #333; font-size: 20px;">학생 인증을 완료해주세요</h2>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
            <p style="color: #333; font-size: 16px; line-height: 1.6; margin-bottom: 20px;">
              안녕하세요! EveryCourse에서 학생 인증을 요청하신 것을 확인했습니다.
            </p>
            
            <p style="color: #666; font-size: 14px; margin-bottom: 25px;">
              아래 인증 코드를 앱에 입력하여 학생 인증을 완료해주세요:
            </p>
            
            <div style="background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 20px; border-radius: 8px; margin: 30px 0; text-align: center;">
              <p style="color: #856404; font-size: 18px; margin: 0;">
                <strong>인증 코드</strong>
              </p>
              <p style="color: #333; font-size: 24px; font-weight: bold; font-family: monospace; background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin: 10px 0;">
                $verificationToken
              </p>
              <p style="color: #856404; font-size: 12px; margin: 0;">
                이 코드를 EveryCourse 앱의 인증 화면에 입력해주세요.
              </p>
            </div>
          </div>
          
          <div style="border-top: 1px solid #dee2e6; padding-top: 20px;">
            <p style="color: #6c757d; font-size: 12px; text-align: center;">
              이 인증 링크는 24시간 후 만료됩니다.<br>
              본인이 요청하지 않은 경우 이 메일을 무시해주세요.
            </p>
            <p style="color: #6c757d; font-size: 12px; text-align: center; margin-top: 15px;">
              © 2024 EveryCourse. 캠퍼스 중심 데이트 코스 추천 서비스
            </p>
          </div>
        </div>
        ''';

      // 이메일 발송
      final sendReport = await send(message, smtpServer);
      print('✅ 이메일 발송 성공: ${sendReport.toString()}');

      return true;
    } catch (e) {
      print('❌ 이메일 발송 실패: $e');
      return false;
    }
  }

  /// 테스트용 간단한 이메일 발송
  static Future<bool> sendTestEmail(String recipientEmail) async {
    try {
      final smtpServer = gmail(_senderEmail, _senderPassword);

      final message = Message()
        ..from = Address(_senderEmail, 'EveryCourse')
        ..recipients.add(recipientEmail)
        ..subject = '📧 EveryCourse 테스트 메일'
        ..text = '안녕하세요! EveryCourse에서 보낸 테스트 메일입니다. 📧';

      final sendReport = await send(message, smtpServer);
      print('✅ 테스트 이메일 발송 성공: ${sendReport.toString()}');

      return true;
    } catch (e) {
      print('❌ 테스트 이메일 발송 실패: $e');
      return false;
    }
  }
}

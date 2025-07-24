# EveryCourse 📚




## 🚀 개발 환경 설정

### 1. 저장소 클론
```bash
git clone <repository-url>
cd everycourse
```

### 2. 필수 파일 추가
프로젝트를 빌드하기 전에 다음 파일들을 추가해주세요:

#### 🔐 Android 서명 설정 (필수)
`android/key.properties` 파일을 생성하고 다음 내용을 추가:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../app/debug.keystore
```

#### 🔑 키스토어 파일 (릴리스 빌드용)
- 개발용: Android의 기본 debug.keystore 사용
- 릴리스용: `android/app/release-key.keystore` 추가 (팀 리더에게 문의)

#### 🔥 Firebase 설정 (Firebase 사용 시)
```
android/app/google-services.json          # Android용
lib/firebase_options.dart                 # Flutter용 Firebase 설정
```

#### 🤐 API 키 설정 (필요 시)
`assets/secrets.json` 파일을 생성하고 필요한 API 키 추가:
```json
{
  "api_key": "your_api_key",
  "secret_key": "your_secret_key"
}
```

### 3. 의존성 설치 및 빌드
```bash
flutter pub get
flutter run
```

## 🛠️ 기술 스택

- **Frontend**: Flutter (Dart)
- **Build System**: Groovy (Android Gradle)
- **Platform**: Android 
- **Architecture**: Material Design 3

## 📁 프로젝트 구조

```
everycourse/
├── lib/                    # Flutter 소스 코드
│   └── main.dart          # 앱 진입점
├── android/               # Android 네이티브 코드
│   ├── app/
│   │   └── build.gradle   # Groovy 빌드 스크립트
│   └── build.gradle       # 루트 빌드 설정
├── assets/                # 리소스 파일
└── test/                  # 테스트 코드
```

## 🔧 Groovy 빌드 시스템 특징

- **빌드 타입별 설정**: Debug/Release 환경 분리
- **ProGuard 최적화**: 릴리스 빌드 시 코드 난독화
- **유틸리티 함수**: 버전 관리 자동화
- **소스 세트 커스터마이징**: Kotlin/Java 혼합 지원

## 🤝 협업 가이드

### Git 워크플로우
1. 기능별 브랜치 생성: `feature/기능명`
2. 개발 완료 후 Pull Request 생성
3. 코드 리뷰 후 main 브랜치로 병합

### 빌드 명령어
```bash
# 개발 빌드
flutter run

# 릴리스 APK 생성
flutter build apk --release

# AAB 생성 (Play Store 배포용)
flutter build appbundle --release
```

### 📱 Android Studio에서 실행하기

#### 1. Android Studio 설정
1. **Android Studio** 실행
2. **File > Open**을 선택하고 `everycourse` 프로젝트 폴더 열기
3. Flutter/Dart 플러그인이 설치되어 있는지 확인:
   - **File > Settings > Plugins**
   - "Flutter"와 "Dart" 플러그인 활성화

#### 2. 디바이스 설정
- **물리 디바이스**: USB 디버깅 활성화 후 연결
- **에뮬레이터**: AVD Manager에서 Android 에뮬레이터 생성

#### 3. 실행 방법
```bash
# 1. 터미널에서 직접 실행
flutter run

# 2. Android Studio UI 사용
# - 상단 툴바에서 타겟 디바이스 선택
# - 재생 버튼(▶️) 클릭 또는 Shift+F10

# 3. 특정 모드로 실행
flutter run --debug    # 디버그 모드
flutter run --release  # 릴리스 모드
flutter run --profile  # 프로파일링 모드
```

#### 4. 핫 리로드 사용
- **r 키**: 핫 리로드 (UI 변경사항 즉시 반영)
- **R 키**: 핫 리스타트 (앱 전체 재시작)
- **Android Studio**: 번개 아이콘(⚡) 클릭

#### 5. 문제 해결
```bash
# Flutter Doctor 실행 (환경 점검)
flutter doctor

# 의존성 재설치
flutter clean
flutter pub get

# Gradle 캐시 정리 (Android 빌드 문제 시)
cd android
./gradlew clean
```

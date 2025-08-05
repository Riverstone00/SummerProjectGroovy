# EveryCourse 📚




## 🚀 개발 환경 설정

### 1. 저장소 클론
```bash
git clone <repository-url>
cd everycourse
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

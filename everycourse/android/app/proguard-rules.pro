# EveryCourse 앱용 ProGuard 규칙

# Flutter 관련 규칙 유지
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-dontwarn io.flutter.**

# 앱 특정 클래스 유지
-keep class com.everycourse.app.** { *; }

# Gson 관련 (JSON 처리용)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# OkHttp 관련 (네트워킹용)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

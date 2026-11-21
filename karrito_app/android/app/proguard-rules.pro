# Keep Flutter entry points and plugin wrappers used via reflection/JNI.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep sqlite3_flutter_libs native loader intact for Drift.
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }

# Keep AndroidX Credential Manager & Google Identity classes used by google_sign_in_android.
-keep class androidx.credentials.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }

# Suppress optional compile-only annotation warnings during R8 shrinking.
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.slf4j.**

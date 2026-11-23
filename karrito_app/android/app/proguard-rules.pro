# Keep Flutter entry points and plugin wrappers used via reflection/JNI.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep AndroidX Startup, WorkManager, and Room generated `_Impl` databases intact
# under AGP 9 / R8 full mode (prevents WorkDatabase_Impl crash pulled by play-services-ads).
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.room.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }

# Keep sqlite3_flutter_libs native loader intact for Drift.
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }

# Keep Dart JNI bridge classes used by path_provider / shared_preferences.
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }

# Keep AndroidX Credential Manager & Google Identity classes used by google_sign_in_android.
-keep class androidx.credentials.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }

# Keep Google Mobile Ads, Google Play Billing, RevenueCat, Firebase, Record,
# Mobile Scanner, and Image Compress classes loaded via reflection.
-keep class com.google.android.gms.ads.** { *; }
-keep class com.android.billingclient.** { *; }
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.llfbandit.record.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-keep class com.fluttercandies.flutter_image_compress.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Suppress optional compile-only annotation warnings during R8 shrinking.
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.slf4j.**
-dontwarn com.revenuecat.**
-dontwarn androidx.room.paging.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.example.nss2.** { *; }

# Keep MainActivity and prevent obfuscation
-keep class com.example.nss2.MainActivity { *; }

# Keep Parcelable models
-keep class * implements android.os.Parcelable { *; }

# General ProGuard rules
-dontwarn android.support.**
-keepattributes *Annotation*
-keep class androidx.** { *; }
-keep class io.flutter.** { *; }

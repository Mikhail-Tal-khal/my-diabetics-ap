# Flutter default keep rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google ML Kit - keep all classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# TensorFlow Lite - keep GPU, NNAPI, and core classes
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Play Services / Firebase (often used by ML Kit internally)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# AndroidX Camera (if used for ML Kit input)
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Keep Kotlin metadata (needed for reflection)
-keep class kotlin.Metadata { *; }

# Prevent stripping of enum values
-keepclassmembers enum * { *; }

# General safety net for reflection-based libs
-keepattributes *Annotation*

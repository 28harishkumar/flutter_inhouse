# Keep TryInhouse SDK classes
-keep class co.tryinhouse.android.** { *; }

# Keep classes used by reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
} 
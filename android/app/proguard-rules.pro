# Hive keeping rules
-keep class io.hive.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.ceo3.focus.** { *; }

# Keep the generated adapters
-keep class * extends io.hive.TypeAdapter { *; }

# Riverpod keep rules
-keep class com.google.crypto.tink.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.util.PathUtils { *; }
-keep class io.flutter.repo.Service { *; }
-keep class io.flutter.view.AccessibilityBridge { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# Don't warn for missing classes
-dontwarn io.flutter.embedding.**
-dontwarn io.hive.**

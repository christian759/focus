import 'package:hive/hive.dart';

part 'app_limit.g.dart';

@HiveType(typeId: 3)
class AppLimit extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final int dailyLimitSeconds; // Duration in seconds

  @HiveField(3)
  final int usedTodaySeconds; // Duration in seconds

  @HiveField(4)
  final bool isEnabled;

  AppLimit({
    required this.packageName,
    required this.appName,
    required this.dailyLimitSeconds,
    required this.usedTodaySeconds,
    this.isEnabled = false,
  });

  Duration get dailyLimit => Duration(seconds: dailyLimitSeconds);
  Duration get usedToday => Duration(seconds: usedTodaySeconds);

  AppLimit copyWith({
    String? packageName,
    String? appName,
    int? dailyLimitSeconds,
    int? usedTodaySeconds,
    bool? isEnabled,
  }) {
    return AppLimit(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      dailyLimitSeconds: dailyLimitSeconds ?? this.dailyLimitSeconds,
      usedTodaySeconds: usedTodaySeconds ?? this.usedTodaySeconds,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
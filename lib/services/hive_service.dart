import 'package:hive_flutter/hive_flutter.dart';
import '../models/session.dart';
import '../models/streak.dart';
import '../models/app_limit.dart';

class HiveService {
  static const String sessionBoxName = 'sessions';
  static const String streakBoxName = 'streaks';
  static const String appLimitsBoxName = 'app_limits';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(SessionStatusAdapter());
    Hive.registerAdapter(SessionModelAdapter());
    Hive.registerAdapter(StreakModelAdapter());
    Hive.registerAdapter(AppLimitAdapter());

    // Open Boxes
    await Hive.openBox<SessionModel>(sessionBoxName);
    await Hive.openBox<StreakModel>(streakBoxName);
    await Hive.openBox<AppLimit>(appLimitsBoxName);
  }

  static Box<SessionModel> get sessionBox => Hive.box<SessionModel>(sessionBoxName);
  static Box<StreakModel> get streakBox => Hive.box<StreakModel>(streakBoxName);
  static Box<AppLimit> get appLimitsBox => Hive.box<AppLimit>(appLimitsBoxName);

  static Future<void> saveSession(SessionModel session) async {
    await sessionBox.put(session.id, session);
  }

  static List<SessionModel> getAllSessions() {
    return sessionBox.values.toList();
  }

  static StreakModel? getStreak() {
    return streakBox.get('current_streak');
  }

  static Future<void> saveStreak(StreakModel streak) async {
    await streakBox.put('current_streak', streak);
  }
}

<div align="center">

# ⚡ Focus+

<img src="https://img.shields.io/badge/Focus+-Productivity_Redefined-00E5A0?style=for-the-badge&logoColor=white" />

<h3>Silence the noise. Reclaim your time. ✨</h3>

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.5-764ABC?style=flat&logo=dart&logoColor=white)](https://riverpod.dev)
[![HiveDB](https://img.shields.io/badge/Hive-NoSQL-FFCA28?style=flat)](#architecture)
[![Premium UI](https://img.shields.io/badge/UI-Glassmorphic-00B8D4?style=flat)](#design-system)

</div>

---

## 💎 The Vision

Focus+ is not just another Pomodoro timer. It is an **environment orchestrator** built natively for Android to forcefully eliminate digital distractions. Wrapped in a premium "Electric Teal" glassmorphic UI, Focus+ uses deep system-level Android permissions to block apps, manage your to-dos, and gamify your focus journey.

---

## 🚀 Core Features

### 🛡️ System-Level App Blocking (DND Service)
Focus+ uses a custom Android `MethodChannel` (`com.ceo3.focus/blocking`) to interact directly with the OS via `StrictlyBlockService`. 
- **Deep Focus Mode**: Hard-blocks your specified blacklisted apps. If you try to open a blocked app, the system intercepts and redirects you safely away.
- **Passive Shielding**: Non-intrusive background blocking, ideal for maintaining boundaries without starting a formal timer.
- **Daily App Limits**: Automatically sets limits on high-usage apps (e.g. 30min daily max on social media) utilizing the local Android `AppLimiter` plugin.

### ⏱️ Session & Goal Management
- **Focus Timer**: A robust background timer backed by Riverpod state management.
- **Lifecycle Awareness**: Utilizes a `LifecycleObserver` to ensure focus sessions aren't cheated or interrupted improperly when the app goes into the background.
- **Daily Goals**: Configurable daily minute goals saved locally using `SharedPreferences`.

### ✅ Integrated Todo System
- Never leave the app to check what you need to do next. The integrated Todo system allows you to build lists and set specific, high-priority native alarms (`FlutterLocalNotificationsPlugin`) for tasks.
- Precise exact-alarms via Android 12+ APIs ensuring you never miss a deadline.

### 🔥 Gamification & Streaks
- **Daily Streaks**: Encourages consistency. Opening the app and completing goals maintains your streak. Missing days resets the counter automatically via the `StreakNotifier`.
- **Advanced Stats**: Beautiful weekly bar charts tracking your focus history and progress natively parsed from `Hive` NoSQL storage.

---

## 🎨 Premium Design System

The app is built around a distinct **Premium Dark Mode** (`AppTheme.darkTheme`).
- **Color Palette**: Deep elevated blacks (`#0D0D0D`) contrasted by vibrant Electric Teal (`#00E5A0`) and Cyan (`#00B8D4`).
- **Glassmorphism**: Extensive use of `BackdropFilter` and translucent borders to create a premium glass effect (`x08FFFFFF`).
- **Dynamic Backgrounds**: Features a custom `PremiumBackground` with procedural `CurvePainter` drawing low-opacity glowing bezier curves for an active, living UI feel.
- **Typography**: Clean, modern text utilizing the `GoogleFonts.inter` family.

---

## 🛠️ Technical Architecture

### Tech Stack
- **Framework**: Flutter / Dart
- **State Management**: flutter_riverpod (`StateNotifierProvider`)
- **Local Database**: Hive (for Limits, Sessions, and Streaks)
- **Settings Store**: SharedPreferences
- **Native Android**: Kotlin MethodChannels for `StrictlyBlockService` and `AppLimiter`.

### State Orchestration
The heart of the app runs through the `GlobalBlockOrchestratorProvider`. This master provider listens to the `FocusProvider`, `PassiveBlockingProvider`, and `AppLimitsProvider` simultaneously to smartly dictate exactly which apps the native Android Android subsystem should block at any given millisecond.

### Directory Structure

```text
lib/
├── core/               # Theme tokens, colors, gradients
├── features/
│   ├── app_limiter/    # Daily usage tracking & limit logic
│   ├── dnd/            # System-level blocking bindings (MethodChannel)
│   ├── focus/          # Timers, Lifecycle observation, daily goals
│   ├── streak/         # Gamification logic
│   ├── todo/           # Task management & alarm scheduling
│   └── user/           # Onboarding & user state
├── models/             # Hive TypeAdapters (Session, Streak, AppLimit)
├── services/           # Services (HiveService, AlarmService, DndService)
└── ui/
    ├── screens/        # Setup, Home, Stats, Focus Active Screen
    └── widgets/        # PremiumBackground, 3D Duration Picker, Gauges
```

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK `^3.11.3`
- **Android SDK**: Min API 21 required. (Note: Features like exact alarms rely on Android 12+, while DND requires system permissions). iOS is not currently supported for deep DND blocking.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/The-honoured1/focus.git
   ```

2. **Fetch Dependencies:**
   ```bash
   cd focus
   flutter pub get
   ```

3. **Generate Code (Required for Hive & Riverpod):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```
   > **Note:** For the blocking features to work, ensure you test on a physical Android device and grant "Usage Access" and "Do Not Disturb" permissions when prompted.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with precision. Designed for depth.</sub>
  <br/>
  <b>Focus+ Android</b>
</div>

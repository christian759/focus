import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../features/todo/todo_provider.dart';
import '../widgets/premium_background.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentMonth;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  List<DateTime?> _generateMonthGrid() {
    final firstOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // Monday = 1, Sunday = 7 — shift to 0-indexed (Mon=0)
    final startWeekday = (firstOfMonth.weekday - 1) % 7;

    final List<DateTime?> grid = [];

    // Leading empty slots
    for (int i = 0; i < startWeekday; i++) {
      grid.add(null);
    }

    // Day slots
    for (int d = 1; d <= daysInMonth; d++) {
      grid.add(DateTime(_currentMonth.year, _currentMonth.month, d));
    }

    return grid;
  }

  void _showAlarmDialog(Todo todo) {
    TimeOfDay selectedTime = TimeOfDay.now();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.border)),
        title: Text('Set Reminder', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set an alarm for "${todo.title}"',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: ctx,
                  initialTime: selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                          onPrimary: Colors.black,
                          surface: AppColors.cardBackground,
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  selectedTime = picked;
                  (ctx as Element).markNeedsBuild();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.alarm_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Builder(builder: (context) {
                      return Text(
                        selectedTime.format(context),
                        style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(todoProvider.notifier).setAlarm(todo.id, selectedTime);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primary.withOpacity(0.9),
                  content: Row(
                    children: [
                      const Icon(Icons.alarm_on_rounded, color: Colors.black, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Reminder set for ${selectedTime.format(context)}',
                        style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Set Alarm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTodos = ref.watch(todoProvider);
    final todos = allTodos.where((todo) => _isSameDay(todo.date, _selectedDate)).toList();
    final monthGrid = _generateMonthGrid();

    // Pre-calculate which days have tasks for dot indicators
    final daysWithTasks = <int>{};
    for (final todo in allTodos) {
      if (todo.date.year == _currentMonth.year && todo.date.month == _currentMonth.month) {
        daysWithTasks.add(todo.date.day);
      }
    }

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Month Nav Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM').format(_currentMonth),
                          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('yyyy').format(_currentMonth),
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _navButton(Icons.chevron_left_rounded, _goToPreviousMonth),
                        const SizedBox(width: 8),
                        _navButton(Icons.chevron_right_rounded, _goToNextMonth),
                      ],
                    ),
                  ],
                ).animate().fadeIn(),
              ),
              const SizedBox(height: 20),

              // Weekday Headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) =>
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.inter(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Calendar Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: monthGrid.length,
                  itemBuilder: (context, index) {
                    final date = monthGrid[index];
                    if (date == null) return const SizedBox(); // empty slot

                    final isSelected = _isSameDay(date, _selectedDate);
                    final isToday = _isSameDay(date, DateTime.now());
                    final hasTasks = daysWithTasks.contains(date.day);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isToday && !isSelected
                              ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.black : isToday ? AppColors.primary : Colors.white70,
                              ),
                            ),
                            if (hasTasks && !isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasTasks && isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Selected Date Label + Task Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isSameDay(_selectedDate, DateTime.now())
                          ? 'Today\'s Tasks'
                          : DateFormat('EEEE, MMM d').format(_selectedDate),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${todos.length} task${todos.length == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 12),

              // Add Task Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _taskController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () {
                        if (_taskController.text.trim().isNotEmpty) {
                          ref.read(todoProvider.notifier).addTodo(
                            _taskController.text.trim(),
                            date: _selectedDate,
                          );
                          _taskController.clear();
                        }
                      },
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      ref.read(todoProvider.notifier).addTodo(
                        val.trim(),
                        date: _selectedDate,
                      );
                      _taskController.clear();
                    }
                  },
                ).animate().fadeIn(delay: 200.ms),
              ),
              const SizedBox(height: 12),

              // Tasks List
              Expanded(
                child: todos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.task_alt_rounded, color: Colors.white12, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No tasks for this day',
                              style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (_) => ref.read(todoProvider.notifier).toggleTodo(todo.id),
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  side: BorderSide(color: Colors.white24),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: TextStyle(
                                          color: todo.isCompleted ? Colors.white38 : Colors.white,
                                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (todo.alarmTime != null)
                                        Row(
                                          children: [
                                            Icon(Icons.alarm_rounded, color: AppColors.primary.withOpacity(0.7), size: 13),
                                            const SizedBox(width: 4),
                                            Text(
                                              todo.alarmTime!,
                                              style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.7), fontSize: 11),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.alarm_add_rounded, color: Colors.white24, size: 20),
                                  onPressed: () => _showAlarmDialog(todo),
                                  tooltip: 'Set reminder',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                                  onPressed: () => ref.read(todoProvider.notifier).deleteTodo(todo.id),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 200 + (index * 50)));
                        },
                      ),
              ),
              // Avoid overlap with bottom nav
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }
}

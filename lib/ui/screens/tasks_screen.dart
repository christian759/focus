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
  late List<DateTime> _weekDays;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _generateWeekDays() {
    final now = DateTime.now();
    // Starts from 3 days ago to 3 days ahead (7 days total)
    _weekDays = List.generate(7, (i) => now.subtract(Duration(days: 3)).add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Calendar',
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                
                // Calendar Strip
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _weekDays.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final date = _weekDays[index];
                      final isSelected = _isSameDay(date, _selectedDate);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 65,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
                              width: 1,
                            )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('E').format(date).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isSelected ? Colors.black54 : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn().slideX(begin: 0.1),
                
                const SizedBox(height: 32),
                Text(
                  'To-Do List',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                
                // Add Task Input
                TextField(
                  controller: _taskController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () {
                        if (_taskController.text.trim().isNotEmpty) {
                          ref.read(todoProvider.notifier).addTodo(_taskController.text.trim());
                          _taskController.clear();
                        }
                      },
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      ref.read(todoProvider.notifier).addTodo(val.trim());
                      _taskController.clear();
                    }
                  },
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                
                // Tasks List
                Expanded(
                  child: todos.isEmpty 
                    ? Center(
                        child: Text(
                          'No tasks for today. Take a break!',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: todo.isCompleted,
                            title: Text(
                              todo.title, 
                              style: TextStyle(
                                color: todo.isCompleted ? Colors.white38 : Colors.white, 
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              )
                            ),
                            onChanged: (_) => ref.read(todoProvider.notifier).toggleTodo(todo.id),
                            controlAffinity: ListTileControlAffinity.leading,
                            checkColor: Colors.black,
                            activeColor: AppColors.primary,
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white38),
                              onPressed: () => ref.read(todoProvider.notifier).deleteTodo(todo.id),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 50)));
                        },
                      ),
                ),
                // Avoid overlap with bottom nav
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/alarm_service.dart';

class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime date;
  final String? alarmTime; // e.g. "14:30"

  Todo({
    required this.id, 
    required this.title, 
    required this.date,
    this.isCompleted = false,
    this.alarmTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 
    'title': title, 
    'isCompleted': isCompleted,
    'date': date.toIso8601String(),
    'alarmTime': alarmTime,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'],
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
        alarmTime: json['alarmTime'],
      );
}

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      state = jsonList.map((e) => Todo.fromJson(e)).toList();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((t) => t.toJson()).toList();
    await prefs.setString('todos', jsonEncode(jsonList));
  }

  void addTodo(String title, {DateTime? date}) {
    if (title.trim().isEmpty) return;
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date ?? DateTime.now(),
    );
    state = [...state, newTodo];
    _saveTodos();
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return Todo(
          id: todo.id, 
          title: todo.title, 
          isCompleted: !todo.isCompleted,
          date: todo.date,
          alarmTime: todo.alarmTime,
        );
      }
      return todo;
    }).toList();
    _saveTodos();
  }

  void setAlarm(String id, TimeOfDay time) {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.map((todo) {
      if (todo.id == id) {
        // Calculate the future DateTime for the alarm
        final alarmDate = DateTime(
          todo.date.year,
          todo.date.month,
          todo.date.day,
          time.hour,
          time.minute,
        );
        
        // Schedule the alarm
        AlarmService.scheduleAlarm(todo.id, todo.title, alarmDate);

        return Todo(
          id: todo.id,
          title: todo.title,
          isCompleted: todo.isCompleted,
          date: todo.date,
          alarmTime: timeStr,
        );
      }
      return todo;
    }).toList();
    _saveTodos();
  }

  void deleteTodo(String id) {
    AlarmService.cancelAlarm(id);
    state = state.where((todo) => todo.id != id).toList();
    _saveTodos();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

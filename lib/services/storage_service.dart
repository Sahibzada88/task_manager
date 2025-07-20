import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _themeKey = 'dark_mode';
  static const String _settingsKey = 'app_settings';

  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);

      if (tasksJson == null) return [];

      final List<dynamic> tasksList = json.decode(tasksJson);
      return tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  Future<bool> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveThemePreference(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode);
    } catch (e) {
      throw Exception('Failed to save theme preference: $e');
    }
  }

  Future<Map<String, dynamic>> loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        return {
          'notifications_enabled': true,
          'default_priority': 'medium',
          'default_category': 'General',
          'auto_delete_completed': false,
        };
      }

      return json.decode(settingsJson);
    } catch (e) {
      return {
        'notifications_enabled': true,
        'default_priority': 'medium',
        'default_category': 'General',
        'auto_delete_completed': false,
      };
    }
  }

  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings);
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  Future<int> getStorageSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          totalSize += value.length;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

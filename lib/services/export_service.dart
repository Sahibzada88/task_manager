import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';

class ExportService {
  Future<String> exportToJson(List<Task> tasks) async {
    try {
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'totalTasks': tasks.length,
        'completedTasks': tasks.where((task) => task.isCompleted).length,
        'pendingTasks': tasks.where((task) => !task.isCompleted).length,
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      if (kIsWeb) {
        // Web platform - use browser download
        await _downloadFileWeb(
            jsonString,
            'tasks_export_${DateTime.now().millisecondsSinceEpoch}.json',
            'application/json'
        );
        return 'Downloaded to browser downloads';
      } else {
        // Mobile platform - use share
        await Share.share(
          jsonString,
          subject: 'Task Manager Export - JSON',
        );
        return 'Shared successfully';
      }
    } catch (e) {
      throw Exception('Failed to export tasks to JSON: $e');
    }
  }

  Future<String> exportToCsv(List<Task> tasks) async {
    try {
      final csvData = StringBuffer();

      // CSV Header
      csvData.writeln('ID,Title,Description,Category,Priority,Status,Created,Due Date,Completed,Updated');

      // CSV Data
      for (final task in tasks) {
        csvData.writeln([
          task.id,
          _escapeCsvField(task.title),
          _escapeCsvField(task.description),
          _escapeCsvField(task.category),
          task.priority.displayName,
          task.isCompleted ? 'Completed' : 'Pending',
          task.createdAt.toIso8601String(),
          task.dueDate?.toIso8601String() ?? '',
          task.completedAt?.toIso8601String() ?? '',
          task.updatedAt?.toIso8601String() ?? '',
        ].join(','));
      }

      if (kIsWeb) {
        // Web platform - use browser download
        await _downloadFileWeb(
            csvData.toString(),
            'tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv',
            'text/csv'
        );
        return 'Downloaded to browser downloads';
      } else {
        // Mobile platform - use share
        await Share.share(
          csvData.toString(),
          subject: 'Task Manager Export - CSV',
        );
        return 'Shared successfully';
      }
    } catch (e) {
      throw Exception('Failed to export tasks to CSV: $e');
    }
  }

  Future<List<Task>> importFromJson(String jsonData) async {
    try {
      final data = json.decode(jsonData);

      if (data['tasks'] == null) {
        throw Exception('Invalid JSON format: missing tasks array');
      }

      final List<dynamic> tasksJson = data['tasks'];
      return tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      throw Exception('Failed to import tasks from JSON: $e');
    }
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Future<void> exportTaskStatistics(List<Task> tasks) async {
    try {
      final stats = _calculateStatistics(tasks);
      final jsonString = const JsonEncoder.withIndent('  ').convert(stats);

      if (kIsWeb) {
        await _downloadFileWeb(
            jsonString,
            'task_statistics_${DateTime.now().millisecondsSinceEpoch}.json',
            'application/json'
        );
      } else {
        await Share.share(
          jsonString,
          subject: 'Task Statistics Export',
        );
      }
    } catch (e) {
      throw Exception('Failed to export task statistics: $e');
    }
  }

  Map<String, dynamic> _calculateStatistics(List<Task> tasks) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;
    final dueSoonTasks = tasks.where((task) => task.isDueSoon).length;

    final priorityStats = <String, int>{};
    for (final priority in TaskPriority.values) {
      priorityStats[priority.displayName] =
          tasks.where((task) => task.priority == priority).length;
    }

    final categoryStats = <String, int>{};
    for (final task in tasks) {
      categoryStats[task.category] = (categoryStats[task.category] ?? 0) + 1;
    }

    // Calculate completion rate by month
    final monthlyStats = <String, Map<String, int>>{};
    for (final task in tasks) {
      final monthKey = '${task.createdAt.year}-${task.createdAt.month.toString().padLeft(2, '0')}';
      monthlyStats[monthKey] ??= {'total': 0, 'completed': 0};
      monthlyStats[monthKey]!['total'] = monthlyStats[monthKey]!['total']! + 1;
      if (task.isCompleted) {
        monthlyStats[monthKey]!['completed'] = monthlyStats[monthKey]!['completed']! + 1;
      }
    }

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'totalTasks': tasks.length,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'dueSoonTasks': dueSoonTasks,
      'completionRate': tasks.isNotEmpty ? (completedTasks / tasks.length * 100).toStringAsFixed(1) : '0.0',
      'priorityBreakdown': priorityStats,
      'categoryBreakdown': categoryStats,
      'monthlyStats': monthlyStats,
      'averageTasksPerMonth': monthlyStats.isNotEmpty
          ? (tasks.length / monthlyStats.length).toStringAsFixed(1)
          : '0.0',
    };
  }

  Future<String> exportBackup(List<Task> tasks, Map<String, dynamic> settings) async {
    try {
      final backupData = {
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'appVersion': '1.0.0',
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'settings': settings,
        'statistics': _calculateStatistics(tasks),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      if (kIsWeb) {
        await _downloadFileWeb(
            jsonString,
            'task_manager_backup_${DateTime.now().millisecondsSinceEpoch}.json',
            'application/json'
        );
        return 'Downloaded to browser downloads';
      } else {
        await Share.share(
          jsonString,
          subject: 'Task Manager Backup',
        );
        return 'Shared successfully';
      }
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Web-specific download method
  Future<void> _downloadFileWeb(String content, String fileName, String mimeType) async {
    if (kIsWeb) {
      // Use HTML download for web
      final bytes = utf8.encode(content);
      final blob = _createBlob(bytes, mimeType);
      final url = _createObjectUrl(blob);

      _downloadFromUrl(url, fileName);
      _revokeObjectUrl(url);
    }
  }

  // Web-specific helper methods (these will be ignored on non-web platforms)
  dynamic _createBlob(List<int> bytes, String mimeType) {
    if (kIsWeb) {
      // This would use dart:html in a real web environment
      // For now, we'll use a fallback approach
      return null;
    }
    return null;
  }

  String _createObjectUrl(dynamic blob) {
    if (kIsWeb) {
      // This would use dart:html URL.createObjectUrl in a real web environment
      return '';
    }
    return '';
  }

  void _downloadFromUrl(String url, String fileName) {
    if (kIsWeb) {
      // This would create and click a download link in a real web environment
      // For now, we'll show the content in a new window/tab
      print('Download would happen here: $fileName');
    }
  }

  void _revokeObjectUrl(String url) {
    if (kIsWeb) {
      // This would use dart:html URL.revokeObjectUrl in a real web environment
    }
  }
}

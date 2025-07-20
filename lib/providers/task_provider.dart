import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final ExportService _exportService = ExportService();

  List<Task> _tasks = [];
  TaskStatus _currentFilter = TaskStatus.all;
  String _searchQuery = '';
  bool _isDarkMode = false;
  bool _isLoading = false;
  String _sortBy = 'createdAt';
  bool _sortAscending = false;

  List<Task> get tasks {
    List<Task> filteredTasks = List.from(_tasks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) =>
      task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    switch (_currentFilter) {
      case TaskStatus.completed:
        filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
        break;
      case TaskStatus.pending:
        filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskStatus.overdue:
        filteredTasks = filteredTasks.where((task) => task.isOverdue).toList();
        break;
      case TaskStatus.dueSoon:
        filteredTasks = filteredTasks.where((task) => task.isDueSoon).toList();
        break;
      case TaskStatus.all:
      default:
        break;
    }

    // Apply sorting
    filteredTasks.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'priority':
          comparison = b.priority.value.compareTo(a.priority.value);
          break;
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) comparison = 0;
          else if (a.dueDate == null) comparison = 1;
          else if (b.dueDate == null) comparison = -1;
          else comparison = a.dueDate!.compareTo(b.dueDate!);
          break;
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filteredTasks;
  }

  TaskStatus get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isCompleted).length;
  int get totalTasksCount => _tasks.length;
  int get overdueTasksCount => _tasks.where((task) => task.isOverdue).length;
  int get dueSoonTasksCount => _tasks.where((task) => task.isDueSoon).length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _storageService.loadTasks();
      _isDarkMode = await _storageService.loadThemePreference();

      // Schedule notifications for tasks with due dates
      await _scheduleNotifications();

    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = task.copyWith(
        updatedAt: DateTime.now(),
      );

      _tasks.add(newTask);
      await _storageService.saveTasks(_tasks);

      // Schedule notification if task has due date
      if (newTask.dueDate != null) {
        await _notificationService.scheduleTaskNotification(newTask);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      final taskWithUpdate = updatedTask.copyWith(
        updatedAt: DateTime.now(),
      );

      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = taskWithUpdate;
        await _storageService.saveTasks(_tasks);

        // Update notification
        await _notificationService.cancelTaskNotification(taskWithUpdate.id);
        if (taskWithUpdate.dueDate != null && !taskWithUpdate.isCompleted) {
          await _notificationService.scheduleTaskNotification(taskWithUpdate);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      _tasks.removeWhere((task) => task.id == taskId);
      await _storageService.saveTasks(_tasks);

      // Cancel notification
      await _notificationService.cancelTaskNotification(taskId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final task = _tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      rethrow;
    }
  }

  void setFilter(TaskStatus filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSorting(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  List<String> get categories {
    final categorySet = _tasks.map((task) => task.category).toSet();
    return ['General', ...categorySet.where((cat) => cat != 'General')];
  }

  Future<void> _scheduleNotifications() async {
    for (final task in _tasks) {
      if (task.dueDate != null && !task.isCompleted) {
        await _notificationService.scheduleTaskNotification(task);
      }
    }
  }

  Future<String> exportTasksToJson() async {
    try {
      return await _exportService.exportToJson(_tasks);
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      rethrow;
    }
  }

  Future<String> exportTasksToCsv() async {
    try {
      return await _exportService.exportToCsv(_tasks);
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      rethrow;
    }
  }

  Future<void> importTasksFromJson(String jsonData) async {
    try {
      final importedTasks = await _exportService.importFromJson(jsonData);

      for (final task in importedTasks) {
        await addTask(task);
      }
    } catch (e) {
      debugPrint('Error importing tasks: $e');
      rethrow;
    }
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority && !task.isCompleted).toList();
  }

  List<Task> getOverdueTasks() {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<Task> getDueSoonTasks() {
    return _tasks.where((task) => task.isDueSoon).toList();
  }

  Future<void> clearAllTasks() async {
    try {
      _tasks.clear();
      await _storageService.saveTasks(_tasks);

      // Cancel all notifications
      for (final task in _tasks) {
        await _notificationService.cancelTaskNotification(task.id);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing tasks: $e');
      rethrow;
    }
  }

  Future<void> clearCompletedTasks() async {
    try {
      final completedTasks = _tasks.where((task) => task.isCompleted).toList();

      for (final task in completedTasks) {
        await _notificationService.cancelTaskNotification(task.id);
      }

      _tasks.removeWhere((task) => task.isCompleted);
      await _storageService.saveTasks(_tasks);

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing completed tasks: $e');
      rethrow;
    }
  }
}

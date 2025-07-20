import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should create a task with default values', () {
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
      );

      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.category, 'General');
      expect(task.priority, TaskPriority.medium);
      expect(task.isCompleted, false);
      expect(task.id, isNotEmpty);
      expect(task.createdAt, isNotNull);
    });

    test('should create a task with custom values', () {
      final dueDate = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        title: 'Custom Task',
        description: 'Custom Description',
        category: 'Work',
        priority: TaskPriority.high,
        dueDate: dueDate,
        isCompleted: true,
      );

      expect(task.title, 'Custom Task');
      expect(task.description, 'Custom Description');
      expect(task.category, 'Work');
      expect(task.priority, TaskPriority.high);
      expect(task.dueDate, dueDate);
      expect(task.isCompleted, true);
    });

    test('should convert task to JSON and back', () {
      final originalTask = Task(
        title: 'JSON Task',
        description: 'JSON Description',
        category: 'Test',
        priority: TaskPriority.urgent,
        isCompleted: true,
      );

      final json = originalTask.toJson();
      final recreatedTask = Task.fromJson(json);

      expect(recreatedTask.id, originalTask.id);
      expect(recreatedTask.title, originalTask.title);
      expect(recreatedTask.description, originalTask.description);
      expect(recreatedTask.category, originalTask.category);
      expect(recreatedTask.priority, originalTask.priority);
      expect(recreatedTask.isCompleted, originalTask.isCompleted);
    });

    test('should copy task with updated values', () {
      final originalTask = Task(
        title: 'Original Task',
        description: 'Original Description',
        priority: TaskPriority.low,
      );

      final updatedTask = originalTask.copyWith(
        title: 'Updated Task',
        priority: TaskPriority.high,
        isCompleted: true,
      );

      expect(updatedTask.id, originalTask.id);
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.description, originalTask.description);
      expect(updatedTask.priority, TaskPriority.high);
      expect(updatedTask.isCompleted, true);
    });

    test('should detect overdue tasks', () {
      final overdueTask = Task(
        title: 'Overdue Task',
        description: 'This task is overdue',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final futureTask = Task(
        title: 'Future Task',
        description: 'This task is not overdue',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      final completedOverdueTask = Task(
        title: 'Completed Overdue Task',
        description: 'This task is completed',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: true,
      );

      expect(overdueTask.isOverdue, true);
      expect(futureTask.isOverdue, false);
      expect(completedOverdueTask.isOverdue, false);
    });

    test('should detect tasks due soon', () {
      final dueSoonTask = Task(
        title: 'Due Soon Task',
        description: 'This task is due soon',
        dueDate: DateTime.now().add(const Duration(hours: 12)),
      );

      final futureTask = Task(
        title: 'Future Task',
        description: 'This task is not due soon',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );

      final completedDueSoonTask = Task(
        title: 'Completed Due Soon Task',
        description: 'This task is completed',
        dueDate: DateTime.now().add(const Duration(hours: 12)),
        isCompleted: true,
      );

      expect(dueSoonTask.isDueSoon, true);
      expect(futureTask.isDueSoon, false);
      expect(completedDueSoonTask.isDueSoon, false);
    });
  });

  group('TaskPriority Extension Tests', () {
    test('should return correct display names', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
      expect(TaskPriority.urgent.displayName, 'Urgent');
    });

    test('should return correct priority values', () {
      expect(TaskPriority.low.value, 1);
      expect(TaskPriority.medium.value, 2);
      expect(TaskPriority.high.value, 3);
      expect(TaskPriority.urgent.value, 4);
    });
  });
}

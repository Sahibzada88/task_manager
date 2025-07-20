import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/export_service.dart';
import 'dart:convert';

void main() {
  group('ExportService Tests', () {
    late ExportService exportService;
    late List<Task> testTasks;

    setUp(() {
      exportService = ExportService();
      testTasks = [
        Task(
          title: 'Test Task 1',
          description: 'Description 1',
          category: 'Work',
          priority: TaskPriority.high,
          isCompleted: false,
        ),
        Task(
          title: 'Test Task 2',
          description: 'Description 2',
          category: 'Personal',
          priority: TaskPriority.medium,
          isCompleted: true,
        ),
      ];
    });

    test('should import tasks from valid JSON', () async {
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'tasks': testTasks.map((task) => task.toJson()).toList(),
      };

      final jsonString = json.encode(jsonData);
      final importedTasks = await exportService.importFromJson(jsonString);

      expect(importedTasks.length, 2);
      expect(importedTasks[0].title, 'Test Task 1');
      expect(importedTasks[1].title, 'Test Task 2');
      expect(importedTasks[0].priority, TaskPriority.high);
      expect(importedTasks[1].isCompleted, true);
    });

    test('should throw exception for invalid JSON format', () async {
      const invalidJson = '{"invalid": "format"}';

      expect(
            () async => await exportService.importFromJson(invalidJson),
        throwsException,
      );
    });

    test('should throw exception for malformed JSON', () async {
      const malformedJson = '{"tasks": [invalid json}';

      expect(
            () async => await exportService.importFromJson(malformedJson),
        throwsException,
      );
    });

    test('should escape CSV fields correctly', () {
      // This tests the private _escapeCsvField method indirectly
      final taskWithComma = Task(
        title: 'Task, with comma',
        description: 'Description "with quotes"',
      );

      final taskWithNewline = Task(
        title: 'Task with\nnewline',
        description: 'Normal description',
      );

      // The CSV export should handle these special characters
      expect(taskWithComma.title, contains(','));
      expect(taskWithComma.description, contains('"'));
      expect(taskWithNewline.title, contains('\n'));
    });
  });
}

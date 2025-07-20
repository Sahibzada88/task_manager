import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';

void main() {
  group('TaskProvider Tests', () {
    late TaskProvider taskProvider;

    setUp(() {
      taskProvider = TaskProvider();
    });

    test('should start with empty task list', () {
      expect(taskProvider.tasks, isEmpty);
      expect(taskProvider.totalTasksCount, 0);
      expect(taskProvider.completedTasksCount, 0);
      expect(taskProvider.pendingTasksCount, 0);
    });

    test('should add task correctly', () async {
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
      );

      await taskProvider.addTask(task);

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.title, 'Test Task');
      expect(taskProvider.totalTasksCount, 1);
      expect(taskProvider.pendingTasksCount, 1);
      expect(taskProvider.completedTasksCount, 0);
    });

    test('should update task correctly', () async {
      final task = Task(
        title: 'Original Task',
        description: 'Original Description',
      );

      await taskProvider.addTask(task);

      final updatedTask = task.copyWith(
        title: 'Updated Task',
        description: 'Updated Description',
      );

      await taskProvider.updateTask(updatedTask);

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.title, 'Updated Task');
      expect(taskProvider.tasks.first.description, 'Updated Description');
    });

    test('should delete task correctly', () async {
      final task = Task(
        title: 'Task to Delete',
        description: 'This task will be deleted',
      );

      await taskProvider.addTask(task);
      expect(taskProvider.tasks.length, 1);

      await taskProvider.deleteTask(task.id);
      expect(taskProvider.tasks.length, 0);
    });

    test('should toggle task completion correctly', () async {
      final task = Task(
        title: 'Task to Complete',
        description: 'This task will be completed',
      );

      await taskProvider.addTask(task);
      expect(taskProvider.tasks.first.isCompleted, false);
      expect(taskProvider.pendingTasksCount, 1);
      expect(taskProvider.completedTasksCount, 0);

      await taskProvider.toggleTaskCompletion(task.id);
      expect(taskProvider.tasks.first.isCompleted, true);
      expect(taskProvider.pendingTasksCount, 0);
      expect(taskProvider.completedTasksCount, 1);
    });

    test('should filter tasks by status correctly', () async {
      final task1 = Task(title: 'Task 1', description: 'Description 1');
      final task2 = Task(title: 'Task 2', description: 'Description 2', isCompleted: true);
      final task3 = Task(title: 'Task 3', description: 'Description 3');

      await taskProvider.addTask(task1);
      await taskProvider.addTask(task2);
      await taskProvider.addTask(task3);

      // Test all tasks
      taskProvider.setFilter(TaskStatus.all);
      expect(taskProvider.tasks.length, 3);

      // Test pending tasks
      taskProvider.setFilter(TaskStatus.pending);
      expect(taskProvider.tasks.length, 2);
      expect(taskProvider.tasks.every((task) => !task.isCompleted), true);

      // Test completed tasks
      taskProvider.setFilter(TaskStatus.completed);
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.every((task) => task.isCompleted), true);
    });

    test('should search tasks correctly', () async {
      final task1 = Task(title: 'Flutter Development', description: 'Build mobile app');
      final task2 = Task(title: 'React Project', description: 'Web development');
      final task3 = Task(title: 'Database Design', description: 'Flutter backend');

      await taskProvider.addTask(task1);
      await taskProvider.addTask(task2);
      await taskProvider.addTask(task3);

      // Search by title
      taskProvider.setSearchQuery('Flutter');
      expect(taskProvider.tasks.length, 2);

      // Search by description
      taskProvider.setSearchQuery('Web');
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.title, 'React Project');

      // Clear search
      taskProvider.setSearchQuery('');
      expect(taskProvider.tasks.length, 3);
    });

    test('should sort tasks correctly', () async {
      final task1 = Task(
        title: 'B Task',
        description: 'Second task',
        priority: TaskPriority.low,
      );
      final task2 = Task(
        title: 'A Task',
        description: 'First task',
        priority: TaskPriority.high,
      );
      final task3 = Task(
        title: 'C Task',
        description: 'Third task',
        priority: TaskPriority.medium,
      );

      await taskProvider.addTask(task1);
      await taskProvider.addTask(task2);
      await taskProvider.addTask(task3);

      // Sort by title ascending
      taskProvider.setSorting('title', true);
      expect(taskProvider.tasks.first.title, 'A Task');
      expect(taskProvider.tasks.last.title, 'C Task');

      // Sort by priority descending (default)
      taskProvider.setSorting('priority', false);
      expect(taskProvider.tasks.first.priority, TaskPriority.high);
      expect(taskProvider.tasks.last.priority, TaskPriority.low);
    });

    test('should get tasks by priority correctly', () async {
      final lowTask = Task(title: 'Low Priority', description: 'Low', priority: TaskPriority.low);
      final highTask = Task(title: 'High Priority', description: 'High', priority: TaskPriority.high);
      final urgentTask = Task(title: 'Urgent Priority', description: 'Urgent', priority: TaskPriority.urgent);

      await taskProvider.addTask(lowTask);
      await taskProvider.addTask(highTask);
      await taskProvider.addTask(urgentTask);

      final lowPriorityTasks = taskProvider.getTasksByPriority(TaskPriority.low);
      final highPriorityTasks = taskProvider.getTasksByPriority(TaskPriority.high);
      final urgentPriorityTasks = taskProvider.getTasksByPriority(TaskPriority.urgent);

      expect(lowPriorityTasks.length, 1);
      expect(highPriorityTasks.length, 1);
      expect(urgentPriorityTasks.length, 1);
      expect(lowPriorityTasks.first.title, 'Low Priority');
      expect(highPriorityTasks.first.title, 'High Priority');
      expect(urgentPriorityTasks.first.title, 'Urgent Priority');
    });

    test('should get overdue tasks correctly', () async {
      final overdueTask = Task(
        title: 'Overdue Task',
        description: 'This is overdue',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final futureTask = Task(
        title: 'Future Task',
        description: 'This is not overdue',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      await taskProvider.addTask(overdueTask);
      await taskProvider.addTask(futureTask);

      final overdueTasks = taskProvider.getOverdueTasks();
      expect(overdueTasks.length, 1);
      expect(overdueTasks.first.title, 'Overdue Task');
    });

    test('should get due soon tasks correctly', () async {
      final dueSoonTask = Task(
        title: 'Due Soon Task',
        description: 'This is due soon',
        dueDate: DateTime.now().add(const Duration(hours: 12)),
      );
      final futureTask = Task(
        title: 'Future Task',
        description: 'This is not due soon',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );

      await taskProvider.addTask(dueSoonTask);
      await taskProvider.addTask(futureTask);

      final dueSoonTasks = taskProvider.getDueSoonTasks();
      expect(dueSoonTasks.length, 1);
      expect(dueSoonTasks.first.title, 'Due Soon Task');
    });

    test('should get categories correctly', () async {
      final task1 = Task(title: 'Task 1', description: 'Desc 1', category: 'Work');
      final task2 = Task(title: 'Task 2', description: 'Desc 2', category: 'Personal');
      final task3 = Task(title: 'Task 3', description: 'Desc 3', category: 'Work');

      await taskProvider.addTask(task1);
      await taskProvider.addTask(task2);
      await taskProvider.addTask(task3);

      final categories = taskProvider.categories;
      expect(categories.contains('General'), true);
      expect(categories.contains('Work'), true);
      expect(categories.contains('Personal'), true);
      expect(categories.length, 3);
    });
  });
}

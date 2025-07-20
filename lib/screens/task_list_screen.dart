import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/filter_chips.dart';
import '../widgets/search_bar.dart';
import '../widgets/stats_card.dart';
import '../widgets/priority_overview.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('TaskFlow'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'sort':
                    _showSortBottomSheet();
                    break;
                  case 'export':
                    _showExportDialog();
                    break;
                  case 'clear_completed':
                    _showClearCompletedDialog();
                    break;
                  case 'settings':
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem(Icons.sort_rounded, 'Sort', 'sort'),
                _buildPopupMenuItem(Icons.download_rounded, 'Export', 'export'),
                _buildPopupMenuItem(Icons.clear_all_rounded, 'Clear Completed', 'clear_completed'),
                _buildPopupMenuItem(Icons.settings_rounded, 'Settings', 'settings'),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading your tasks...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Stats Card
              const SliverToBoxAdapter(child: StatsCard()),

              // Priority Overview - Only show on larger screens
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return const SizedBox.shrink();
                    }
                    return const PriorityOverview();
                  },
                ),
              ),

              // Search Bar
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: CustomSearchBar(),
                ),
              ),

              // Filter Chips - Always visible
              const SliverToBoxAdapter(child: FilterChips()),

              // Add scroll hint for small screens
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              size: 16,
                              color: const Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Swipe to see all filters',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF6366F1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Task List or Empty State
              taskProvider.tasks.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState(taskProvider))
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final task = taskProvider.tasks[index];
                      return TaskTile(
                        task: task,
                        onTap: () => _navigateToEditTask(context, task),
                        onToggle: () => taskProvider.toggleTaskCompletion(task.id),
                        onDelete: () => _showDeleteConfirmation(context, task),
                      );
                    },
                    childCount: taskProvider.tasks.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _navigateToAddTask(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TaskProvider taskProvider) {
    String message;
    IconData icon;
    String subtitle;

    if (taskProvider.searchQuery.isNotEmpty) {
      message = 'No Results Found';
      subtitle = 'Try adjusting your search terms';
      icon = Icons.search_off_rounded;
    } else if (taskProvider.currentFilter != TaskStatus.all) {
      message = taskProvider.currentFilter == TaskStatus.completed
          ? 'No Completed Tasks'
          : taskProvider.currentFilter == TaskStatus.overdue
          ? 'No Overdue Tasks'
          : taskProvider.currentFilter == TaskStatus.dueSoon
          ? 'No Tasks Due Soon'
          : 'No Pending Tasks';
      subtitle = 'Tasks will appear here when available';
      icon = Icons.task_alt_rounded;
    } else {
      message = 'Ready to Get Started?';
      subtitle = 'Create your first task and boost your productivity!';
      icon = Icons.rocket_launch_rounded;
    }

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (taskProvider.currentFilter == TaskStatus.all && taskProvider.searchQuery.isEmpty) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddTask(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Your First Task'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Keep all existing methods unchanged
  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );
  }

  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskProvider>().deleteTask(task.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Sort Tasks',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Sort by section
                            Text(
                              'Sort by',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Sort options
                            _buildSortOption(
                              context,
                              taskProvider,
                              'createdAt',
                              'Created Date',
                              Icons.access_time,
                            ),
                            _buildSortOption(
                              context,
                              taskProvider,
                              'priority',
                              'Priority',
                              Icons.flag,
                            ),
                            _buildSortOption(
                              context,
                              taskProvider,
                              'dueDate',
                              'Due Date',
                              Icons.event,
                            ),
                            _buildSortOption(
                              context,
                              taskProvider,
                              'title',
                              'Title',
                              Icons.title,
                            ),

                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 20),

                            // Order section
                            Text(
                              'Order',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Ascending/Descending options
                            _buildOrderOption(
                              context,
                              taskProvider,
                              true,
                              'Ascending',
                              Icons.arrow_upward,
                            ),
                            _buildOrderOption(
                              context,
                              taskProvider,
                              false,
                              'Descending',
                              Icons.arrow_downward,
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
      BuildContext context,
      TaskProvider taskProvider,
      String value,
      String title,
      IconData icon,
      ) {
    final isSelected = taskProvider.sortBy == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        )
            : null,
        onTap: () {
          taskProvider.setSorting(value, taskProvider.sortAscending);
        },
      ),
    );
  }

  Widget _buildOrderOption(
      BuildContext context,
      TaskProvider taskProvider,
      bool ascending,
      String title,
      IconData icon,
      ) {
    final isSelected = taskProvider.sortAscending == ascending;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        )
            : null,
        onTap: () {
          taskProvider.setSorting(taskProvider.sortBy, ascending);
        },
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Tasks'),
          content: const Text('Choose export format:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<TaskProvider>().exportTasksToJson();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tasks exported to JSON')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              child: const Text('JSON'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<TaskProvider>().exportTasksToCsv();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tasks exported to CSV')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              child: const Text('CSV'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Completed Tasks'),
          content: const Text('Are you sure you want to delete all completed tasks? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<TaskProvider>().clearCompletedTasks();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Completed tasks cleared')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to clear tasks: $e')),
                    );
                  }
                }
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

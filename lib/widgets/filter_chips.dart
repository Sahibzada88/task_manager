import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Filter Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              // Scrollable filter chips with proper controller
              Container(
                height: 45,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          'All',
                          TaskStatus.all,
                          taskProvider.currentFilter,
                          taskProvider.setFilter,
                          taskProvider.totalTasksCount,
                          Icons.dashboard_rounded,
                          const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Pending',
                          TaskStatus.pending,
                          taskProvider.currentFilter,
                          taskProvider.setFilter,
                          taskProvider.pendingTasksCount,
                          Icons.pending_actions_rounded,
                          const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Done',
                          TaskStatus.completed,
                          taskProvider.currentFilter,
                          taskProvider.setFilter,
                          taskProvider.completedTasksCount,
                          Icons.check_circle_rounded,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Overdue',
                          TaskStatus.overdue,
                          taskProvider.currentFilter,
                          taskProvider.setFilter,
                          taskProvider.overdueTasksCount,
                          Icons.warning_rounded,
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Due Soon',
                          TaskStatus.dueSoon,
                          taskProvider.currentFilter,
                          taskProvider.setFilter,
                          taskProvider.dueSoonTasksCount,
                          Icons.schedule_rounded,
                          const Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 20), // Extra padding at the end
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
      BuildContext context,
      String label,
      TaskStatus status,
      TaskStatus currentFilter,
      Function(TaskStatus) onSelected,
      int count,
      IconData icon,
      Color color,
      ) {
    final isSelected = currentFilter == status;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(status),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: isSelected ? null : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 6),
                Text(
                  '$label ($count)',
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

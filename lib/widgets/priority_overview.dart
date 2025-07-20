import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class PriorityOverview extends StatelessWidget {
  const PriorityOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Priority Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.maxWidth < 400
                      ? _buildCompactPriorityView(taskProvider)
                      : _buildFullPriorityView(taskProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullPriorityView(TaskProvider taskProvider) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final count = taskProvider.getTasksByPriority(priority).length;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildPriorityCard(priority, count),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactPriorityView(TaskProvider taskProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TaskPriority.values.map((priority) {
          final count = taskProvider.getTasksByPriority(priority).length;
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: _buildPriorityCard(priority, count),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriorityCard(TaskPriority priority, int count) {
    final color = _getPriorityColor(priority);

    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: minimize the column size
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10), // Smaller radius
            ),
            child: Icon(
              _getPriorityIcon(priority),
              color: color,
              size: 20, // Smaller icon
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20, // Smaller font
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2), // Reduced spacing
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: 12, // Smaller font
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFFFFB800);
      case TaskPriority.high:
        return const Color(0xFFFF6B6B);
      case TaskPriority.urgent:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.trending_down_rounded;
      case TaskPriority.medium:
        return Icons.trending_flat_rounded;
      case TaskPriority.high:
        return Icons.trending_up_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onToggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: task.isCompleted
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: task.isCompleted
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: task.isCompleted
                                  ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                color: task.isCompleted
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(task.priority),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getPriorityColor(task.priority).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      constraints.maxWidth < 300
                          ? _buildCompactChips(context)
                          : _buildFullChips(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildChip(
              context,
              task.category,
              Icons.folder_rounded,
              const Color(0xFF6366F1),
            ),
            const SizedBox(width: 8),
            if (task.isOverdue)
              _buildChip(
                context,
                'OVERDUE',
                Icons.warning_rounded,
                const Color(0xFFFF6B6B),
              )
            else if (task.isDueSoon)
              _buildChip(
                context,
                'DUE SOON',
                Icons.schedule_rounded,
                const Color(0xFFFFB800),
              ),
          ],
        ),
        if (task.dueDate != null) ...[
          const SizedBox(height: 8),
          _buildChip(
            context,
            'Due: ${_formatDate(task.dueDate!)}',
            Icons.event_rounded,
            _getDueDateColor(context, task.dueDate!),
          ),
        ],
      ],
    );
  }

  Widget _buildFullChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          context,
          task.category,
          Icons.folder_rounded,
          const Color(0xFF6366F1),
        ),
        _buildChip(
          context,
          _formatDate(task.createdAt),
          Icons.access_time_rounded,
          const Color(0xFF8B5CF6),
        ),
        if (task.dueDate != null)
          _buildChip(
            context,
            'Due: ${_formatDate(task.dueDate!)}',
            Icons.event_rounded,
            _getDueDateColor(context, task.dueDate!),
          ),
        if (task.isOverdue)
          _buildChip(
            context,
            'OVERDUE',
            Icons.warning_rounded,
            const Color(0xFFFF6B6B),
          ),
        if (task.isDueSoon && !task.isOverdue)
          _buildChip(
            context,
            'DUE SOON',
            Icons.schedule_rounded,
            const Color(0xFFFFB800),
          ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getDueDateColor(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return const Color(0xFFFF6B6B); // Overdue
    } else if (difference <= 1) {
      return const Color(0xFFFFB800); // Due soon
    } else {
      return const Color(0xFF10B981); // Normal
    }
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
}

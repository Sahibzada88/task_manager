import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'General';
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  bool _isLoading = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedCategory = widget.task!.category;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
      if (widget.task!.dueDate != null) {
        _selectedDueTime = TimeOfDay.fromDateTime(widget.task!.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCategoryDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildPriorityDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _buildDueDatePicker(),
            const SizedBox(height: 16),
            _buildDueTimePicker(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Title is required';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final categories = taskProvider.categories;

        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        );
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<TaskPriority>(
      value: _selectedPriority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag),
      ),
      items: TaskPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _getPriorityColor(priority),
              ),
              const SizedBox(width: 8),
              Text(priority.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPriority = value!;
        });
      },
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: _selectDueDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due Date (Optional)',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: _selectedDueDate != null
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _selectedDueDate = null;
                _selectedDueTime = null;
              });
            },
          )
              : const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          _selectedDueDate != null
              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
              : 'Select due date',
          style: TextStyle(
            color: _selectedDueDate != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDueTimePicker() {
    return InkWell(
      onTap: _selectedDueDate != null ? _selectDueTime : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due Time (Optional)',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.access_time),
          suffixIcon: _selectedDueTime != null
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _selectedDueTime = null;
              });
            },
          )
              : const Icon(Icons.arrow_drop_down),
          enabled: _selectedDueDate != null,
        ),
        child: Text(
          _selectedDueTime != null
              ? _selectedDueTime!.format(context)
              : 'Select due time',
          style: TextStyle(
            color: _selectedDueTime != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(isEditing ? 'Update' : 'Save'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  DateTime? _combineDateAndTime() {
    if (_selectedDueDate == null) return null;

    if (_selectedDueTime != null) {
      return DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedDueTime!.hour,
        _selectedDueTime!.minute,
      );
    }

    return _selectedDueDate;
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();
      final dueDateTime = _combineDateAndTime();

      if (isEditing) {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: dueDateTime,
        );
        await taskProvider.updateTask(updatedTask);
      } else {
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: dueDateTime,
        );
        await taskProvider.addTask(newTask);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Task updated!' : 'Task added!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }
}

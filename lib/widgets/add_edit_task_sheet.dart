import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';

class AddEditTaskSheet extends StatefulWidget {
  final String userId;
  final TaskModel? task; // null = add mode, non-null = edit mode

  const AddEditTaskSheet({
    super.key,
    required this.userId,
    this.task,
  });

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;

  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _selectedDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bloc = context.read<TaskBloc>();

    if (_isEditMode) {
      final updated = widget.task!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDate,
      );
      bloc.add(TaskUpdated(updated));
    } else {
      final task = TaskModel(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        dueDate: _selectedDate,
        userId: widget.userId,
      );
      bloc.add(TaskAdded(task));
    }

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_task,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditMode ? 'Edit Task' : 'New Task',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Task title input
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Description input
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Priority selector
            Text('Priority',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: TaskPriority.values.map((p) {
                final selected = _selectedPriority == p;
                final color = _priorityColor(p);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.2)
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color : AppTheme.divider,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _priorityIcon(p),
                            color: selected ? color : AppTheme.textHint,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: selected ? color : AppTheme.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Due date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppTheme.primary
                        : AppTheme.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _selectedDate != null
                          ? AppTheme.primary
                          : AppTheme.textHint,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? 'Due: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Set due date (optional)',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? AppTheme.textPrimary
                            : AppTheme.textHint,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppTheme.textHint),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditMode ? 'Update Task' : 'Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return AppTheme.success;
      case TaskPriority.medium:
        return AppTheme.warning;
      case TaskPriority.high:
        return AppTheme.error;
    }
  }

  IconData _priorityIcon(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }
}
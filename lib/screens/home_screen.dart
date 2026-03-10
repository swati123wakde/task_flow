import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/add_edit_task_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskBloc>().add(TaskFetchRequested(authState.user.uid));
    }
  }

  void _openAddTaskSheet(String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: AddEditTaskSheet(userId: userId),
      ),
    );
  }

  void _openEditTaskSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: AddEditTaskSheet(userId: task.userId, task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();
        final user = authState.user;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, user.name),

                // Filter tabs
                _buildFilterBar(context),

                // Task list
                Expanded(
                  child: BlocConsumer<TaskBloc, TaskState>(
                    listener: (context, state) {
                      if (state is TaskOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      } else if (state is TaskError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is TaskLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        );
                      }

                      if (state is TaskLoaded ||
                          state is TaskOperationSuccess) {
                        final loaded = state is TaskLoaded
                            ? state
                            : (state as TaskOperationSuccess).loadedState;
                        return _buildTaskList(context, loaded, user.uid);
                      }

                      if (state is TaskError) {
                        return _buildErrorState(context, user.uid);
                      }

                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddTaskSheet(user.uid),
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // Progress card
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final loaded = _getLoaded(state);
              if (loaded == null) return const SizedBox.shrink();
              return _buildProgressCard(context, loaded);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, TaskLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.completedCount} / ${state.totalCount} tasks',
                    style:
                    Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(state.completionRate * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.completionRate,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.1, duration: 400.ms)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildFilterBar(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final loaded = _getLoaded(state);
        final filter = loaded?.filter ?? TaskFilter.all;

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Row(
            children: TaskFilter.values.map((f) {
              final selected = filter == f;
              final label = _filterLabel(f);
              final count = loaded != null ? _filterCount(loaded, f) : 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<TaskBloc>()
                      .add(TaskFilterChanged(f)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                        selected ? AppTheme.primary : AppTheme.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? Colors.white70
                                : AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(
      BuildContext context, TaskLoaded state, String userId) {
    final tasks = state.filteredTasks;

    if (tasks.isEmpty) {
      return _buildEmptyState(context, state.filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: tasks.length,
      itemBuilder: (ctx, i) {
        final task = tasks[i];
        return TaskTile(
          task: task,
          onToggle: () =>
              context.read<TaskBloc>().add(TaskToggled(task)),
          onEdit: () => _openEditTaskSheet(task),
          onDelete: () => context
              .read<TaskBloc>()
              .add(TaskDeleted(userId: userId, taskId: task.id)),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskFilter filter) {
    final messages = {
      TaskFilter.all: ('No tasks yet!', 'Tap + to add your first task.'),
      TaskFilter.active: ('All caught up!', 'No pending tasks.'),
      TaskFilter.completed:
      ('No completed tasks', 'Complete a task to see it here.'),
    };

    final (title, subtitle) = messages[filter]!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_outlined,
              color: AppTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    )
        .animate()
        .scale(duration: 400.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildErrorState(BuildContext context, String userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load tasks'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                context.read<TaskBloc>().add(TaskFetchRequested(userId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  TaskLoaded? _getLoaded(TaskState state) {
    if (state is TaskLoaded) return state;
    if (state is TaskOperationSuccess) return state.loadedState;
    return null;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _filterLabel(TaskFilter f) {
    switch (f) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.completed:
        return 'Done';
    }
  }

  int _filterCount(TaskLoaded state, TaskFilter f) {
    switch (f) {
      case TaskFilter.all:
        return state.totalCount;
      case TaskFilter.active:
        return state.activeCount;
      case TaskFilter.completed:
        return state.completedCount;
    }
  }
}
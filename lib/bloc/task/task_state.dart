part of 'task_bloc.dart';

enum TaskFilter { all, active, completed }

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskModel> allTasks;
  final TaskFilter filter;

  const TaskLoaded({
    required this.allTasks,
    this.filter = TaskFilter.all,
  });

  List<TaskModel> get filteredTasks {
    switch (filter) {
      case TaskFilter.all:
        return allTasks;
      case TaskFilter.active:
        return allTasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return allTasks.where((t) => t.isCompleted).toList();
    }
  }

  int get totalCount => allTasks.length;
  int get completedCount => allTasks.where((t) => t.isCompleted).length;
  int get activeCount => allTasks.where((t) => !t.isCompleted).length;
  double get completionRate =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;

  TaskLoaded copyWith({
    List<TaskModel>? allTasks,
    TaskFilter? filter,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [allTasks, filter];
}

class TaskOperationSuccess extends TaskState {
  final String message;
  final TaskLoaded loadedState;

  const TaskOperationSuccess({
    required this.message,
    required this.loadedState,
  });

  @override
  List<Object> get props => [message, loadedState];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}
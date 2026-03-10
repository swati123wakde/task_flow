part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskFetchRequested extends TaskEvent {
  final String userId;
  const TaskFetchRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class TaskAdded extends TaskEvent {
  final TaskModel task;
  const TaskAdded(this.task);

  @override
  List<Object> get props => [task];
}

class TaskUpdated extends TaskEvent {
  final TaskModel task;
  const TaskUpdated(this.task);

  @override
  List<Object> get props => [task];
}

class TaskToggled extends TaskEvent {
  final TaskModel task;
  const TaskToggled(this.task);

  @override
  List<Object> get props => [task];
}

class TaskDeleted extends TaskEvent {
  final String userId;
  final String taskId;
  const TaskDeleted({required this.userId, required this.taskId});

  @override
  List<Object> get props => [userId, taskId];
}

class TaskFilterChanged extends TaskEvent {
  final TaskFilter filter;
  const TaskFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}
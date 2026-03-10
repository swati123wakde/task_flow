import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/task_model.dart';
import '../../services/firebase_database_service.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseDatabaseService _dbService;

  TaskBloc({required FirebaseDatabaseService dbService})
      : _dbService = dbService,
        super(const TaskInitial()) {
    on<TaskFetchRequested>(_onFetchTasks);
    on<TaskAdded>(_onAddTask);
    on<TaskUpdated>(_onUpdateTask);
    on<TaskToggled>(_onToggleTask);
    on<TaskDeleted>(_onDeleteTask);
    on<TaskFilterChanged>(_onFilterChanged);
  }

  TaskLoaded _currentLoadedState() {
    final s = state;
    if (s is TaskLoaded) return s;
    if (s is TaskOperationSuccess) return s.loadedState;
    return const TaskLoaded(allTasks: []);
  }

  Future<void> _onFetchTasks(
      TaskFetchRequested event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TaskLoading());
    try {
      final tasks = await _dbService.fetchTasks(event.userId);
      emit(TaskLoaded(allTasks: tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(
      TaskAdded event,
      Emitter<TaskState> emit,
      ) async {
    final prev = _currentLoadedState();
    try {
      final saved = await _dbService.addTask(event.task);
      final updated = [saved, ...prev.allTasks];
      final newState = prev.copyWith(allTasks: updated);
      emit(TaskOperationSuccess(
          message: 'Task added!', loadedState: newState));
      emit(newState);
    } catch (e) {
      emit(TaskError('Failed to add task: ${e.toString()}'));
      emit(prev);
    }
  }

  Future<void> _onUpdateTask(
      TaskUpdated event,
      Emitter<TaskState> emit,
      ) async {
    final prev = _currentLoadedState();
    try {
      await _dbService.updateTask(event.task);
      final updated = prev.allTasks
          .map((t) => t.id == event.task.id ? event.task : t)
          .toList();
      final newState = prev.copyWith(allTasks: updated);
      emit(TaskOperationSuccess(
          message: 'Task updated!', loadedState: newState));
      emit(newState);
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));
      emit(prev);
    }
  }

  Future<void> _onToggleTask(
      TaskToggled event,
      Emitter<TaskState> emit,
      ) async {
    final prev = _currentLoadedState();
    final toggled = event.task.copyWith(isCompleted: !event.task.isCompleted);

    // Optimistic update
    final optimistic = prev.allTasks
        .map((t) => t.id == event.task.id ? toggled : t)
        .toList();
    emit(prev.copyWith(allTasks: optimistic));

    try {
      await _dbService.toggleTask(event.task);
    } catch (e) {
      // Revert on failure
      emit(prev);
      emit(const TaskError('Failed to update task status.'));
    }
  }

  Future<void> _onDeleteTask(
      TaskDeleted event,
      Emitter<TaskState> emit,
      ) async {
    final prev = _currentLoadedState();
    // Optimistic delete
    final optimistic =
    prev.allTasks.where((t) => t.id != event.taskId).toList();
    emit(prev.copyWith(allTasks: optimistic));

    try {
      await _dbService.deleteTask(event.userId, event.taskId);
      emit(TaskOperationSuccess(
        message: 'Task deleted.',
        loadedState: prev.copyWith(allTasks: optimistic),
      ));
      emit(prev.copyWith(allTasks: optimistic));
    } catch (e) {
      // Revert on failure
      emit(prev);
      emit(const TaskError('Failed to delete task.'));
    }
  }

  Future<void> _onFilterChanged(
      TaskFilterChanged event,
      Emitter<TaskState> emit,
      ) async {
    final prev = _currentLoadedState();
    emit(prev.copyWith(filter: event.filter));
  }
}
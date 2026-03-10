import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
class FirebaseDatabaseService {
  static const String _baseUrl =
      'https://todoapp-976b1-default-rtdb.firebaseio.com';

  final String _idToken;

  FirebaseDatabaseService({required String idToken}) : _idToken = idToken;


  Uri _taskUri(String userId, [String? taskId]) {
    final path = taskId != null
        ? '/tasks/$userId/$taskId.json'
        : '/tasks/$userId.json';
    return Uri.parse('$_baseUrl$path?auth=$_idToken');
  }

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  void _assertSuccess(http.Response res, String op) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('$op failed (${res.statusCode}): ${res.body}');
    }
  }


  Future<List<TaskModel>> fetchTasks(String userId) async {
    final res = await http.get(_taskUri(userId), headers: _headers);
    _assertSuccess(res, 'fetchTasks');

    final data = jsonDecode(res.body);
    if (data == null) return [];

    final Map<String, dynamic> tasksMap = data as Map<String, dynamic>;
    return tasksMap.entries
        .map((e) => TaskModel.fromJson(e.key, e.value as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<TaskModel> addTask(TaskModel task) async {
    final res = await http.post(
      _taskUri(task.userId),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    _assertSuccess(res, 'addTask');

    final String generatedId = jsonDecode(res.body)['name'];
    return task.copyWith(id: generatedId);
  }

  Future<void> updateTask(TaskModel task) async {
    final res = await http.put(
      _taskUri(task.userId, task.id),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    _assertSuccess(res, 'updateTask');
  }

  Future<void> toggleTask(TaskModel task) async {
    final res = await http.patch(
      _taskUri(task.userId, task.id),
      headers: _headers,
      body: jsonEncode({'isCompleted': !task.isCompleted}),
    );
    _assertSuccess(res, 'toggleTask');
  }

  Future<void> deleteTask(String userId, String taskId) async {
    final res =
    await http.delete(_taskUri(userId, taskId), headers: _headers);
    _assertSuccess(res, 'deleteTask');
  }
}
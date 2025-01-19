import 'dart:convert';
import '../models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoService {
  static const String _key = 'todos';

  // Cargar las tareas desde localStorage
  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }

  // Guardar las tareas en localStorage
  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = todos.map((todo) => todo.toJson()).toList();
    prefs.setString(_key, jsonEncode(jsonList));
  }
}

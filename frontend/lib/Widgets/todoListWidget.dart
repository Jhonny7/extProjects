// todo_list_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/todoService.dart';
import '../extensions/HexToColor.dart';

class TodoListWidget extends StatefulWidget {
  final DateTime? date; // Recibir la fecha seleccionada como parámetro

  TodoListWidget({this.date}); // Constructor

  @override
  _TodoListWidgetState createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadTodos();
  }

  // Cargar las tareas
  _loadTodos() async {
    _todos = await _todoService.loadTodos();
    setState(() {});
  }

  // Añadir nueva tarea
  _addTodo() {
    if (_controller.text.isEmpty) return;
    print(widget.date);

    // Aquí agregamos la fecha del widget
    setState(() {
      _todos.add(Todo(title: _controller.text, date: widget.date));
    });

    _todoService.saveTodos(_todos);
    _controller.clear();
  }

  // Marcar tarea como completada
  _toggleTodoCompletion(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
    _todoService.saveTodos(_todos);
  }

  // Eliminar tarea
  _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _todoService.saveTodos(_todos);
  }

  String _formatDate(DateTime? date) {
    if (date == null)
      return ''; // Si la fecha es null, retornamos una cadena vacía
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Nombre de la tarea'),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addTodo,
          child: Container(
            width: 100,
            child: const Center(
              child: const Text('Agregar tarea'),
            ),
          ),
        ),
        SizedBox(height: 10), // Espaciado entre el botón y el ListView
        // Aquí definimos una altura para que ListView ocupe el espacio disponible
        Container(
          height:
              600, // Define la altura del contenedor (ajústala según necesites)
          child: ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
              return ListTile(
                title: Text(todo.title),
                subtitle: todo.date != null
                    ? Text('Fecha: ${_formatDate(todo.date)}')
                    : Text('Sin fecha definida'), // Mostrar la fecha
                leading: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => _toggleTodoCompletion(index),
                ),
                trailing: IconButton(
                  icon: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(400),
                    ),
                    child: Center(
                      child: Icon(Icons.delete),
                    ),
                  ),
                  color: "#ec0000".toColor(),
                  onPressed: () => _deleteTodo(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

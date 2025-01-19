import 'package:intl/intl.dart'; // Para formatear la fecha

class Todo {
  String title;
  bool isCompleted;
  DateTime? date;

  Todo({
    required this.title,
    this.isCompleted = false,
    this.date,
  });

  // Convertir de JSON a objeto
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      // Si la fecha existe, la parseamos, de lo contrario, la dejamos como null
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  // Convertir de objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      // Convertimos la fecha a String (si existe)
      'date': date
          ?.toIso8601String(), // o puedes usar un formato diferente si lo prefieres
    };
  }
}

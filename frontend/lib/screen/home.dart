import 'package:flutter/material.dart';
import 'package:flutter_application_1/extensions/HexToColor.dart';
import '../Widgets/todoListWidget.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/localeController.dart';
import '../l10n.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/socketController.dart';
import '../controllers/connectedUsersController.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();
  final ConnectedUsersController connectedUsersController =
      Get.find<ConnectedUsersController>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  Map<String, double> _progressData = {};
  String currentTime = "";
  final TextEditingController _textController =
      TextEditingController(); // Controlador para la caja de texto

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);

    // Conectar el socket si hay un usuario logueado
    if (authController.getUserId.isNotEmpty) {
      socketController.connectSocket(authController.getUserId);

      // Escuchar actualizaciones del estado de usuarios
      socketController.socket.on('update-user-status', (data) {
        print('Actualización del estado de usuarios: $data');
        connectedUsersController.updateConnectedUsers(List<String>.from(data));
      });
    }

    _loadEvents();
    _updateTime();
    _checkAndNotifyEvents();
  }

  void _addEvent(String event, TimeOfDay time) {
    if (event.isNotEmpty) {
      setState(() {
        final formattedTime = time.format(context);
        final fullEvent = '$event - $formattedTime';
        if (_events[_selectedDay] != null) {
          _events[_selectedDay]?.add(fullEvent);
        } else {
          _events[_selectedDay!] = [fullEvent];
        }
      });
      _saveEvents();
    }
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      final Map<String, dynamic> eventsMap = jsonDecode(eventsString);
      setState(() {
        _events = eventsMap.map((key, value) {
          final date = DateTime.parse(key);
          return MapEntry(date, List<String>.from(value));
        });
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<String>> eventsMap = _events.map((key, value) {
      return MapEntry(key.toIso8601String(), value);
    });
    final String eventsString = jsonEncode(eventsMap);
    prefs.setString('events', eventsString);
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  void _checkAndNotifyEvents() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final todayEvents = _events[_selectedDay ?? DateTime.now()] ?? [];

      for (String event in todayEvents) {
        final parts = event.split(' - ');
        if (parts.length == 2) {
          final eventName = parts[0];
          final eventTimeString = parts[1];
          try {
            final eventTime = DateFormat('HH:mm').parse(eventTimeString);
            if (now.hour == eventTime.hour &&
                now.minute == eventTime.minute &&
                now.second == 0) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)
                          ?.translate('notification_title') ??
                      'Notification'),
                  content: Text(AppLocalizations.of(context)
                          ?.translate('event_time_message') ??
                      'It\'s time for the event: $eventName'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );

              // Reproducir sonido personalizado
              _audioPlayer.play(AssetSource('assets/alert_sound.mp3'));
            }
          } catch (e) {
            print('Error al analizar la hora del evento: $eventTimeString');
          }
        }
      }
    });
  }

  void _logout() {
    if (authController.getUserId.isNotEmpty) {
      socketController.disconnectUser(authController.getUserId);

      authController.setUserId('');
      connectedUsersController.updateConnectedUsers([]);
    }

    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController eventController = TextEditingController();
    DateTime selectedTime = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('add_class') ??
              'Add Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                          ?.translate('class_name_label') ??
                      'Class Name',
                ),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.translate('select_time_label') ??
                    'Select Time:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 200,
                child: TimePickerSpinner(
                  is24HourMode: true,
                  normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  highlightedTextStyle:
                      TextStyle(fontSize: 24, color: Colors.blue),
                  spacing: 100,
                  itemHeight: 50,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)?.translate('cancel') ??
                  'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addEvent(
                    eventController.text, TimeOfDay.fromDateTime(selectedTime));
                Navigator.pop(context);
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('save') ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  // En _buildProgressCharts:
  List<Widget> _buildProgressCharts() {
    final Map<String, double> progressData = {};

    _events.forEach((date, events) {
      for (var event in events) {
        final parts = event.split(' - ');
        if (parts.isNotEmpty) {
          final subject = parts[0];
          progressData[subject] = (progressData[subject] ?? 0.0) + 0.1;
        }
      }
    });

    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: progressData.entries.map((entry) {
            Color progressColor = entry.value >= 0.8
                ? Colors.green
                : entry.value >= 0.5
                    ? Colors.orange
                    : Colors.red;

            return Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: entry.value * 100,
                            title: "${(entry.value * 100).toStringAsFixed(1)}%",
                            color: progressColor,
                            radius: 30,
                          ),
                          PieChartSectionData(
                            value: (1 - entry.value) * 100,
                            title: "",
                            color: Colors.grey.shade300,
                            radius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)?.translate('home_page_title') ??
                'Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;
            if (width > 900) {
              return Row(
                children: [
                  // Columna principal (60% de la pantalla)
                  Flexible(
                    flex: 6, // Esto define el 60% del espacio disponible
                    child: Column(
                      children: [
                        TableCalendar(
                          focusedDay: _focusedDay,
                          firstDay: DateTime.utc(2020, 01, 01),
                          lastDay: DateTime.utc(2025, 12, 31),
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            print(selectedDay);
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            _loadEvents();
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)
                                  ?.translate('current_time') ??
                              'Current Time: $currentTime',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showAddEventDialog(context),
                          child: Text(
                            AppLocalizations.of(context)
                                    ?.translate('add_event_button') ??
                                'Add Event',
                          ),
                        ),
                        ..._buildProgressCharts(),
                      ],
                    ),
                  ),

                  // Columna de Container (40% de la pantalla)
                  Flexible(
                    flex: 4, // Esto define el 40% del espacio disponible
                    child: Container(
                      color: "#0176ff".toColor(opacity: 0.4),
                      child: Center(
                        child: TodoListWidget(date: _selectedDay),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  // Contenedor 1 (al 100% de ancho)
                  Container(
                    width: double.infinity,
                    height: (height * .6),
                    child: Column(
                      children: [
                        TableCalendar(
                          focusedDay: _focusedDay,
                          firstDay: DateTime.utc(2020, 01, 01),
                          lastDay: DateTime.utc(2025, 12, 31),
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            print(selectedDay);
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            _loadEvents();
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)
                                  ?.translate('current_time') ??
                              'Current Time: $currentTime',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showAddEventDialog(context),
                          child: Text(
                            AppLocalizations.of(context)
                                    ?.translate('add_event_button') ??
                                'Add Event',
                          ),
                        ),
                        ..._buildProgressCharts(),
                      ],
                    ),
                  ),
                  // Contenedor 2 (al 100% de ancho)
                  Container(
                    width: double.infinity,
                    height: 400,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: "#0176ff".toColor(opacity: 0.4),
                      child: Center(
                        child: TodoListWidget(date: _selectedDay),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await NotificationService().init();
  runApp(const TodoApp());
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  Future<void> scheduleNotification(String title, DateTime dateTime) async {
    await _notifications.zonedSchedule(
      dateTime.hashCode,
      title,
      'ถึงเวลาทำ: $title',
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        cardColor: const Color(0xFF2D2D2D),
        dialogBackgroundColor: const Color(0xFF2E2E2E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF3A3A3A),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  String title;
  DateTime? dateTime;

  Task(this.title, {this.dateTime});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  bool _isLoggedIn = false;

  void _addTask(String taskTitle, DateTime? dateTime) {
    final newTask = Task(taskTitle, dateTime: dateTime);
    setState(() => tasks.add(newTask));

    if (dateTime != null) {
      NotificationService().scheduleNotification(taskTitle, dateTime);
    }
  }

  void _editTask(int index, String newTitle, DateTime? newDateTime) {
    setState(() {
      tasks[index].title = newTitle;
      tasks[index].dateTime = newDateTime;
    });

    if (newDateTime != null) {
      NotificationService().scheduleNotification(newTitle, newDateTime);
    }
  }

  void _deleteTask(int index) {
    setState(() => tasks.removeAt(index));
  }

  void _handleLogin(String email) {
    setState(() => _isLoggedIn = true);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('ยินดีต้อนรับ $email')));
  }

  void _showTaskDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    final taskTitleController = TextEditingController(
        text: isEditing ? tasks[editIndex].title : '');
    DateTime? selectedDateTime =
        isEditing ? tasks[editIndex].dateTime : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'แก้ไขงาน' : 'เพิ่มงานใหม่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskTitleController,
                decoration: const InputDecoration(hintText: 'กรอกงานของคุณ'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDateTime != null
                          ? '${selectedDateTime!.toLocal()}'.substring(0, 16)
                          : 'ไม่กำหนดเวลา',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_calendar, color: Colors.teal),
                    label: const Text('เลือกเวลา'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime ?? DateTime.now().add(const Duration(minutes: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              selectedDateTime ?? DateTime.now()),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  )
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('บันทึก'),
              onPressed: () {
                final title = taskTitleController.text.trim();
                if (title.isNotEmpty) {
                  if (isEditing) {
                    _editTask(editIndex, title, selectedDateTime);
                  } else {
                    _addTask(title, selectedDateTime);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _isLoggedIn ? tasks.length : 0,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: task.dateTime != null
                ? Text(
                    'แจ้งเตือน: ${task.dateTime!.toLocal().toString().substring(0, 16)}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () => _showTaskDialog(editIndex: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteTask(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                setState(() {
                  _isLoggedIn = false;
                  tasks.clear();
                });
              },
            )
          else
<<<<<<< HEAD
TextButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('เข้าสู่ระบบ'),
        content: LoginCard(onLoginSuccess: _handleLogin),
      ),
    );
  },
  child: const Text('Login', style: TextStyle(color: Colors.white)),
),


=======
>>>>>>> f0095817f2568dc577a6473c755383b328fecac7
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10, // สีพื้นหลังโปร่งแสง
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('เข้าสู่ระบบ'),
                        content: LoginCard(onLoginSuccess: _handleLogin),
                      ),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

<<<<<<< HEAD
        child: _buildTaskList(),


        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),child: _buildTaskList(),
 child: _isLoggedIn
=======
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoggedIn
>>>>>>> f0095817f2568dc577a6473c755383b328fecac7
            ? _buildTaskList()
            : Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(33, 255, 255, 255), // พื้นหลังโปร่งแสง
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'ยินดีต้อนรับสู่ Todo App',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(3.5, 3.0),
                            blurRadius: 0.5,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'กรุณาเข้าสู่ระบบก่อนใช้งาน',
                      style: TextStyle(
                        color: Color.fromARGB(136, 255, 43, 43),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
      ),

<<<<<<< HEAD

floatingActionButton: _isLoggedIn
    ? FloatingActionButton(
        onPressed: _showTaskDialog,
        child: const Icon(Icons.add),
      )
    : null,

=======
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () => _showTaskDialog(),
              child: const Icon(Icons.add),
            )
          : null,
>>>>>>> f0095817f2568dc577a6473c755383b328fecac7
    );
  }
}

class LoginCard extends StatefulWidget {
  final void Function(String email) onLoginSuccess;
  const LoginCard({super.key, required this.onLoginSuccess});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final TextEditingController _emailController =
      TextEditingController(text: 'user@example.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '1234');
  String? _errorMessage;

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email == 'user@example.com' && password == '1234') {
      widget.onLoginSuccess(email);
    } else {
      setState(() => _errorMessage = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'อีเมล'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _handleLogin,
          child: const Text('เข้าสู่ระบบ'),
        ),
      ],
    );
  }
}
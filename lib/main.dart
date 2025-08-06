import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'todo_page.dart'; // เชื่อม todo_page.dart

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatefulWidget {
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _selectedIndex = 0;

  final List<String> tasks = [
    'Workout at 6am',
    'Meeting at 10am',
    'Meeting a Book',
    'Read a Book',
  ];

  @override
  void initState() {
    super.initState();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        final payload = notificationResponse.payload;
        if (payload != null) {
          print('Notification payload: $payload');
        }
      },
    );
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'แจ้งเตือน Todo',
      'คุณมีงานที่ต้องทำในวันนี้',
      platformDetails,
      payload: 'ข้อมูลเพิ่มเติม',
    );
  }

  List<Widget> get _pages => [
        _homePage(),
        TodoPage(), // <-- เชื่อมกับ todo_page.dart
        _settingsPage(),
      ];

  Widget _homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LoginCard(),
          SizedBox(height: 20),
          ProfileSection(),
          SizedBox(height: 20),
          ...tasks.map((task) => TodoCard(task: task)).toList(),
          SizedBox(height: 20),
          GlowButton(
            text: 'Add Task',
            icon: Icons.add,
            onPressed: () {},
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showNotification,
            child: Text('แสดงแจ้งเตือน'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _settingsPage() {
    return Center(
      child: Text("Settings Page", style: TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        primaryColor: Colors.blueAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo App'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Color(0xFF2C2C2C),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Welcome Back!', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Login to continue', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Name', style: TextStyle(fontSize: 16)),
              Text('Your profile summary', style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  final String task;

  const TodoCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(task),
        trailing: Icon(Icons.check_circle_outline, color: Colors.green),
      ),
    );
  }
}

class GlowButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const GlowButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
    );
  }
}

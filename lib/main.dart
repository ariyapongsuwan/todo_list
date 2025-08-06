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

  bool _isLoggedIn = false; // สถานะล็อกอิน
  String _userEmail = "";

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
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
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
        TodoPage(), // เชื่อมกับ todo_page.dart
        _settingsPage(),
      ];

  Widget _homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _isLoggedIn
              ? ProfileSection(userEmail: _userEmail)
              : LoginCard(
                  onLoginSuccess: (email) {
                    setState(() {
                      _isLoggedIn = true;
                      _userEmail = email;
                    });
                  },
                ),
          SizedBox(height: 20),
          if (_isLoggedIn) ...[
            ...tasks.map((task) => TodoCard(task: task)).toList(),
            SizedBox(height: 20),
            GlowButton(
              text: 'ใหม่',
              icon: Icons.add,
              onPressed: () {
                _showAddTaskDialog();
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showNotification,
              child: Text('แสดงแจ้งเตือน'),
            ),
            SizedBox(height: 16),
          ]
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

class LoginCard extends StatefulWidget {
  final Function(String email) onLoginSuccess;

  const LoginCard({required this.onLoginSuccess});

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  void _handleLogin() {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = 'กรุณากรอกอีเมลและรหัสผ่านให้ครบ';
    });
    return;
  }

  // ✅ แค่กรอกครบก็ถือว่าล็อกอินสำเร็จ
  widget.onLoginSuccess(email);
}


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Welcome Back!', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Login to continue', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 12),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.redAccent),
                ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('ลงชื่อเข้าใช้'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String userEmail;

  const ProfileSection({required this.userEmail});

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
              Text(userEmail, style: TextStyle(fontSize: 16)),
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

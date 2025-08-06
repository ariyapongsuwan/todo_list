import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Colors.blueAccent),
            title: Text('Account', style: TextStyle(color: Colors.white)),
            subtitle: Text('Manage your account settings', style: TextStyle(color: Colors.grey)),
            onTap: () {
              // ใส่ฟังก์ชัน หรือ navigation ไปหน้าจัดการบัญชี
            },
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.blueAccent),
            title: Text('Notifications', style: TextStyle(color: Colors.white)),
            subtitle: Text('Manage notification settings', style: TextStyle(color: Colors.grey)),
            onTap: () {
              // ฟังก์ชันจัดการแจ้งเตือน
            },
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.palette, color: Colors.blueAccent),
            title: Text('Appearance', style: TextStyle(color: Colors.white)),
            subtitle: Text('Theme and colors', style: TextStyle(color: Colors.grey)),
            onTap: () {
              // ฟังก์ชันเปลี่ยนธีม
            },
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.blueAccent),
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              // ฟังก์ชันออกจากระบบ
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'แอปของฉัน',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Kanit', // ถ้ามี font Kanit ให้ดูดีขึ้น
      ),
      home: SettingsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2; // หน้า 'ตั้งค่า' อยู่ index 2

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // สำหรับตอนนี้พิมพ์ใน console เฉย ๆ
    print("เปลี่ยนเป็นหน้า index: $index");
    // TODO: Navigator.push() ไปหน้าอื่นได้ในอนาคต
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งค่า'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Colors.blueGrey),
            title: Text('แก้ไขข้อมูลหรือโปรไฟล์'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigator.push(...) ไปหน้าแก้ไขข้อมูล
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.blueGrey),
            title: Text('เปลี่ยนรหัสผ่าน'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigator.push(...) ไปหน้าเปลี่ยนรหัสผ่าน
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.blueGrey),
            title: Text('ออกจากระบบ'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // เพิ่มการยืนยันการ logout หรือ Navigator.pop()
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'ฐานความรู้',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }
}

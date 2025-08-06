// lib/todo_page.dart

import 'package:flutter/material.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('หน้ารายการงานของคุณ'),
      ),
    );
  }
}
